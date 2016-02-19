class OnlineResultsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token

  def index
    @language = "english"
  end

  def timedout
    flash[:alert] = "Session timed out."
    redirect_to action: 'index'
  end

  def show
    @username = params['username']
    @password = params['password']
    @language = params['language']
    visits = Visit.includes(:clinic, results: [:test, :status])
      .where(username: @username, password: @password)

    if visits.length != 1
      flash[:alert] = Script.get_message("online_not_found", @language)
      render action: :index
    else
      message = visits.first.get_results_message(@language, "online")

      # Create a record of the message that we sent.
      delivery = Delivery.create(
        delivered_at: Time.now,
        delivery_method: "online",
        message: message
      )
      visits.first.results.each do |result|
        result.deliveries << delivery
      end

      # We use a redirect here as to prevent refreshing from resubmitting the POST.
      session[:message] = message
      redirect_to action: 'results'
    end
  end

  def results
      @message = session[:message]
      session.delete(:message)

      if @message.blank?
        redirect_to action: 'index'
        return
      end

      # Never cache the results page!
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
