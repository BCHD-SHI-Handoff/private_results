class ApiController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token

  # Handles the initial call.
  def welcome
  end

  # Handles initial language prompt when the patient failed to select a language.
  def welcome_repeat
    @error_message = get_message("language_not_selected")
    render action: :welcome
  end

  # Handles initial language prompt when the patient selected a number.
  def welcome_process
    case params["Digits"]
    when "1" then @language_code = "en-US"
    when "2" then @language_code = "es-MX"
    end

    if @language_code
      # Patient has selected a valid language.
      redirect_to action: :enter_username, :language_code => @language_code
    else
      # Patient has not selected a valid language.
      @error_message = get_message("language_not_selected")
      render action: :welcome
    end
  end

  # We should only get here with a valid language_code
  def enter_username
    @language_code = params["language_code"]
    @message = get_message("enter_username", @language_code)
  end

  # Handles username prompt when the patient failed to enter a username.
  def enter_username_repeat
    @language_code = params["language_code"]
    @message = get_message("enter_username", @language_code)
    @error_message = get_message("enter_username_repeat", @language_code)
    render action: :enter_username
  end

  # Handles username prompt when the patient entered a username.
  def enter_username_process
    @language_code = params["language_code"]
    @message = get_message("enter_username", @language_code)

    # XXX do the lookup
    if @visit
      redirect_to action: :enter_username, :language_code => @language_code, :username => username and return
    else
      @error_message = get_message("enter_username_invalid", @language_code)
      render action: :enter_username
    end
  end

  def enter_password
  end

  private

  def get_message(name, code = "en-US")
    Script.select(:message).find_by(
      name: name,
      language: language_code_to_language(code)
    ).message
  end

  def language_code_to_language(code)
    case code
    when "en-US" then "english"
    when "en-MX" then "spanish"
    end
  end
end
