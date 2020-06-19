class Tradetracker
  class ApiError < StandardError
  end

  attr_reader :client

  def initialize(customer_id, api_key)
    @client = Savon.client(
      wsdl: 'http://ws.tradetracker.com/soap/merchant?wsdl'
      # log: true,
      # log_level: :debug,
      # pretty_print_xml: true
    )
    authenticate(customer_id, api_key)
  end

  def click_transactions(*args, **opts)
    handle_exceptions do
      fetch_click_transactions(*args, **opts)
    end
  end

  def conversion_transactions(*args, **opts)
    handle_exceptions do
      fetch_conversion_transactions(*args, **opts)
    end
  end

  private

  def authenticate(customer_id, api_key)
    handle_exceptions do
      # Authenticate and set cookies manually.
      # I would expect that Savon took care of this but apperentaly not.
      client.call(:authenticate, message: { customerID: customer_id, passphrase: api_key }).tap do |response|
        client.globals[:headers] = { 'Cookie' => response.http.headers['Set-Cookie'] }
      end
    end
  end

  def handle_exceptions
    begin
      yield
    rescue Savon::SOAPFault => e
      case e.message
      when /Failed to authenticate/
        raise ApiError.new('Invalid combination of `customer_id` and `api_key`')
      end
    end
  end

  def fetch_click_transactions(from: Date.today - 7, to: Date.today)
    transactions = []
    client.call(:get_click_transactions, message: {
      campaignID:           campaign_id,
      registrationDateFrom: from.to_s,
      registrationDateTo:   to.to_s
    }).tap do |transactions_response|
      transactions_response.body[:get_click_transactions_response][:click_transactions][:item].each do |transaction|
        transactions << transaction.slice(
          :id,
          :transaction_type,
          :transaction_status,
          :currency,
          :commission,
          :ip,
          :referer_url,
          :registration_date
        ).merge(
          affiliate_site_id:   transaction[:affiliate_site][:id],
          affiliate_site_url:  transaction[:affiliate_site][:url],
          affiliate_site_name: transaction[:affiliate_site][:name]
        )
      end
    end
    transactions
  end

  def fetch_conversion_transactions(from: Date.today - 7, to: Date.today)
    transactions = []
    client.call(:get_conversion_transactions, message: {
      campaignID:           campaign_id,
      registrationDateFrom: from.to_s,
      registrationDateTo:   to.to_s
    }).tap do |conversions_response|
      conversions_response.body[:get_conversion_transactions_response][:conversion_transactions][:item].each do |transaction|
        transactions << transaction.slice(
          :id,
          :transaction_type,
          :transaction_status,
          :num_touch_points,
          :num_attributed_touch_points,
          :characteristic,
          :description,
          :currency,
          :commission,
          :order_amount,
          :ip,
          :registration_date,
          :assessment_date,
          :click_to_conversion,
          :originating_click_date,
          :rejection_reason,
          :country_code
        ).merge(
          campaign_product_id:   transaction[:campaign_product][:id],
          campaign_product_name: transaction[:campaign_product][:name],
          campaign_id:           transaction[:campaign][:id],
          campaign_name:         transaction[:campaign][:name],
          campaign_url:          transaction[:campaign][:url],
          affiliate_site_id:     transaction[:affiliate_site][:id],
          affiliate_site_url:    transaction[:affiliate_site][:url],
          affiliate_site_name:   transaction[:affiliate_site][:name]
        )
      end
    end
    transactions
  end

  def campaign_id
    @_campaign_id ||=
      client.call(:get_campaigns).yield_self do |campaigns_response|
        campaigns_response.body[:get_campaigns_response][:campaigns][:item][:id]
      end
  end
end
