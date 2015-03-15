class ApiController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token

  before_action :get_language_code

  before_action :get_username_prompt, only: [
    :username_prompt,
    :username_prompt_repeat,
    :username_prompt_process
  ]

  before_action :get_password_prompt, only: [
    :password_prompt,
    :password_prompt_repeat,
    :password_prompt_process
  ]

  # Handles the initial call.
  def welcome
    @welcome_message = get_message("welcome")
  end

  # Patient failed to select a language at the welcome prompt.
  def welcome_repeat
    @error_message = get_message("language_not_selected")
    render action: :welcome
  end

  # Process the selected language.
  def welcome_process
    case params["Digits"]
    when "1" then language = "english"
    when "2" then language = "spanish"
    end

    if language
      # Patient has selected a valid language, so we store it in their session.
      session[:language] = language
      redirect_to action: :username_prompt
    else
      # Patient has not selected a valid language.
      @error_message = get_message("language_not_selected")
      render action: :welcome
    end
  end

  # Patient selected a valid language, so prompt for username.
  def username_prompt
  end

  # Patient failed to enter a username at the username prompt.
  def username_prompt_repeat
    @error_message = get_message("username_prompt_repeat")
    render action: :username_prompt
  end

  # Process the input username.
  def username_prompt_process
    username = params["Digits"]

    if Visit.exists?(username: username)
      session[:username] = username
      redirect_to action: :password_prompt
    else
      @error_message = get_message("username_prompt_invalid")
      render action: :username_prompt
    end
  end

  # Patient entered a valid username, so prompt for password.
  def password_prompt
  end

  # Patient failed to enter a password at the password prompt.
  def password_prompt_repeat
    @error_message = get_message("password_prompt_repeat")
    render action: :password_prompt
  end

  # Process the input password.
  def password_prompt_process
    password = params["Digits"]
    visit = Visit.find_by(username: session[:username], password: password)
    if visit
      session[:visit_id] = visit.id
      redirect_to action: :deliver_results
    else
      @error_message = get_message("password_prompt_invalid")
      render action: :password_prompt
    end
  end

  def deliver_results
    # XXX Should probably look visit up based on username and password to prevent
    # someone from accessing api/deliver_results with the right visit_id.
    # Although how would they set the visit_id session?
    visit = Visit.find_by_id(session[:visit_id])

    # Set our locale.
    # Twilio likes long locales like "en-US" while rails likes short form and as symbols.
    I18n.locale = get_language_code().split("-").first.to_sym

    template = Liquid::Template.parse(get_message("master")) # Parses and compiles the template
    @message = template.render(
      {
        "clinic_name" => visit.clinic.name,
        "visit_date" => visit.visited_on_date,
        "clinic_hours" => "monday to friday, 8am to 9pm", # XXX clinic model should have hours
        "any_pending" => false,
        "result_ready_on" => nil,
        "any_come_back_to_clinic" => false,
        "test_names" => ["HIV", "Chlamydia", "Hepatitis B"].to_sentence(), # to_sentence will respect I18n.locale
        "test_messages" => ["test message goes here", "another test message"].to_sentence(),
      }
    )
  end

  private

  def get_language_code
    @language_code =
      case session[:language]
      when "english" then "en-US"
      when "spanish" then "es-MX"
      else
        "en-US"
      end
  end

  def get_username_prompt
    @message = get_message("username_prompt")
  end

  def get_password_prompt
    @message = get_message("password_prompt")
  end

  def get_message(name)
    language = session[:language] || "english"
    Script.select(:message).find_by(name: name, language: language).message
  end
end
