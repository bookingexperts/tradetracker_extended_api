class ClickTransactionsController < ApplicationController
  def json
    handle_tradetracker_call do |tradetracker|
      render json: tradetracker.click_transactions({
        from: params[:from],
        to:   params[:to]
      }.compact)
    end
  end

  def csv
    handle_tradetracker_call do |tradetracker|
      render plain: hash_to_csv(
        tradetracker.click_transactions({
          from: params[:from],
          to:   params[:to]
        }.compact)
      )
    end
  end
end
