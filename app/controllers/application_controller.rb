require 'csv'

class ApplicationController < Jets::Controller::Base
  def handle_tradetracker_call
    begin
      tradetracker = Tradetracker.new(params[:customer_id], params[:api_key])
      yield(tradetracker)
    rescue Tradetracker::ApiError => e
      render json: { error: e.message }
    end
  end

  def hash_to_csv(array_of_hashes)
    csv_string = CSV.generate do |csv|
      csv << array_of_hashes.first.keys
      array_of_hashes.each do |hash|
        csv << hash.values
      end
    end
  end
end
