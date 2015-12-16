require 'rails_helper'

describe ApiController, :type => :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/xml'
  end

  describe "error" do
    it "should gracefully handle any internal errors" do
      # Cause an internal error by setting our session language
      # to something that does not exist.
      # This should result in us looking up a script for a language that does not exist,
      # resulting in a FileNotFound exception.
      session[:language] = "bad_language"
      get :username_prompt

      # The exception should get caught and we should return an error.
      expect(response).to render_template(:error)
      expect(assigns(:error_message)).to eq "Sorry, an unknown error occurred, please contact the clinic."
    end
  end

  describe "welcome" do
    it "should set welcome message" do
      get :welcome
      expect(response).to have_http_status(:success) # 200
      expect(assigns(:welcome_message)).to eq Script.get_message("welcome")
      expect(response).to render_template(:welcome)
    end

    it "should set error and render welcome on repeat" do
      get :welcome_repeat
      expect(response).to have_http_status(:success) # 200
      expect(assigns(:error_message)).to eq Script.get_message("language_not_selected")
      expect(response).to render_template(:welcome)
    end

    it "should process english language selection" do
      get :welcome_process, { "Digits" => "1"}
      expect(session[:language]).to eq "english"
      expect(response).to redirect_to :api_username_prompt
    end

    it "should process spanish language selection" do
      get :welcome_process, { "Digits" => "2"}
      expect(session[:language]).to eq "spanish"
      expect(response).to redirect_to :api_username_prompt
    end

    it "should process bad language selection" do
      get :welcome_process, { "Digits" => "9"}
      expect(response).to have_http_status(:success) # 200
      expect(assigns(:error_message)).to eq Script.get_message("language_not_selected")
      expect(response).to render_template(:welcome)
    end
  end

  describe "username prompt" do
    before :each do
      session[:language] = "english"
      @message = Script.get_message("username_prompt")
    end

    it "should set language code and message" do
      get :username_prompt
      expect(response).to have_http_status(:success) # 200
      expect(assigns(:language_code)).to eq "en-US"
      expect(assigns(:message)).to eq @message
      expect(response).to render_template(:username_prompt)
    end

    it "should set error and render username prompt on repeat" do
      get :username_prompt_repeat
      expect(response).to have_http_status(:success) # 200
      expect(assigns(:language_code)).to eq "en-US"
      expect(assigns(:message)).to eq @message
      expect(assigns(:error_message)).to eq Script.get_message("username_prompt_repeat")
      expect(response).to render_template(:username_prompt)
    end

    it "should set error and render username prompt on invalid username" do
      get :username_prompt_process, { "Digits" => "33"}
      expect(response).to have_http_status(:success) # 200
      expect(assigns(:language_code)).to eq "en-US"
      expect(assigns(:message)).to eq @message
      expect(assigns(:error_message)).to eq Script.get_message("username_prompt_invalid").gsub("{{ username }}", "3 3")
      expect(response).to render_template(:username_prompt)
    end

    it "should set username and redirect to password prompt with valid username" do
      visit = create(:visit)
      get :username_prompt_process, { "Digits" => visit.username }
      expect(session[:username]).to eq visit.username
      expect(response).to redirect_to :api_password_prompt
    end
  end

  describe "password prompt" do
    before :each do
      @visit = create(:visit)
      session[:language] = "english"
      session[:username] = @visit.username
      @message = Script.get_message("password_prompt")
    end

    it "should set language code and message" do
      get :password_prompt
      expect(response).to have_http_status(:success) # 200
      expect(assigns(:language_code)).to eq "en-US"
      expect(assigns(:message)).to eq @message
      expect(response).to render_template(:password_prompt)
    end

    it "should set error and render password prompt on repeat" do
      get :password_prompt_repeat
      expect(response).to have_http_status(:success) # 200
      expect(assigns(:language_code)).to eq "en-US"
      expect(assigns(:message)).to eq @message
      expect(assigns(:error_message)).to eq Script.get_message("password_prompt_repeat")
      expect(response).to render_template(:password_prompt)
    end

    it "should set error and render password prompt on invalid password" do
      get :password_prompt_process, { "Digits" => "33"}
      expect(response).to have_http_status(:success) # 200
      expect(assigns(:language_code)).to eq "en-US"
      expect(assigns(:message)).to eq @message
      error_message = Script.get_message("password_prompt_invalid")
      error_message.gsub!("{{ username }}", space_number(@visit.username))
      error_message.gsub!("{{ password }}", "3 3")
      expect(assigns(:error_message)).to eq error_message
      expect(response).to render_template(:password_prompt)
    end

    it "should set visit_id and redirect to deliver results with valid password" do
      get :password_prompt_process, { "Digits" => @visit.password }
      expect(session[:visit_id]).to eq @visit.id
      expect(response).to redirect_to :api_deliver_results
    end
  end

  describe "deliver_results" do
    it "should render results message and create a delivery" do
      visit = create(:visit_with_results)

      # Set our session.
      session = {"visit_id" => visit.id, "language" => "english"}

      # Request our results.
      get(:deliver_results, { "Caller" => "+15551234567" }, session)
      expect(response).to have_http_status(:success) # 200
      expect(response).to render_template(:deliver_results)

      actual_message = visit.get_results_message("english", "phone")
      expect(assigns(:message)).to eq actual_message

      # Each result should point to the recorded delivery.
      visit.results.each do |result|
        expect(result.deliveries.length).to eq 1
        expect(result.deliveries.first.message).to eq actual_message
        # expect(result.deliveries.first.phone_number_used).to eq "+15551234567" // Not recording phone numbers.
        expect(result.deliveries.first.delivery_method).to eq "phone"
      end
    end
  end
end