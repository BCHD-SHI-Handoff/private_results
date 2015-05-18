class OnlineResultsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token

  def index
  end

  def show
    visits = Visit.includes(:clinic, results: [:test, :status])
      .where(username: params['username'], password: params['password'])

    if visits.length != 1
      flash[:alert] = "The password does not match the username that you provided. If you think this is an error, please contact the clinic."
      render action: :index
    else
      @message = visits.first.get_results_message("english", "online")

      # Create a record of the message that we sent.
      delivery = Delivery.create(
        delivered_at: Time.now,
        delivery_method: "online",
        message: @message
      )
      visits.first.results.each do |result|
        result.deliveries << delivery
      end
    end
  end
end
