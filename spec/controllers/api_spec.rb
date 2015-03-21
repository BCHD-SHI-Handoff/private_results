require 'rails_helper'

describe ApiController, :type => :controller do
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/xml'
  end

  describe "welcome" do
    it "should set welcome message" do
      get :welcome
      expect(response).to have_http_status(:success) # 200
      welcome_message = Script.select(:message).find_by(name: "welcome", language: "english").message
      expect(assigns(:welcome_message)).to eq welcome_message
      expect(response).to render_template(:welcome)
    end

    it "should set error and render welcome on repeat" do
      get :welcome_repeat
      expect(response).to have_http_status(:success) # 200
      error_message = Script.select(:message).find_by(name: "language_not_selected", language: "english").message
      expect(assigns(:error_message)).to eq error_message
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
      error_message = Script.select(:message).find_by(name: "language_not_selected", language: "english").message
      expect(assigns(:error_message)).to eq error_message
      expect(response).to render_template(:welcome)
    end
  end

  describe "username prompt" do
    before :each do
      session[:language] = "english"
      @message = Script.select(:message).find_by(name: "username_prompt", language: "english").message
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
      error_message = Script.select(:message).find_by(name: "username_prompt_repeat", language: "english").message
      expect(assigns(:error_message)).to eq error_message
      expect(response).to render_template(:username_prompt)
    end

    it "should set error and render username prompt on invalid username" do
      get :username_prompt_process, { "Digits" => "33"}
      expect(response).to have_http_status(:success) # 200
      expect(assigns(:language_code)).to eq "en-US"
      expect(assigns(:message)).to eq @message
      error_message = Script.select(:message).find_by(name: "username_prompt_invalid", language: "english").message
      expect(assigns(:error_message)).to eq error_message
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
      @message = Script.select(:message).find_by(name: "password_prompt", language: "english").message
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
      error_message = Script.select(:message).find_by(name: "password_prompt_repeat", language: "english").message
      expect(assigns(:error_message)).to eq error_message
      expect(response).to render_template(:password_prompt)
    end

    it "should set error and render password prompt on invalid password" do
      get :password_prompt_process, { "Digits" => "33"}
      expect(response).to have_http_status(:success) # 200
      expect(assigns(:language_code)).to eq "en-US"
      expect(assigns(:message)).to eq @message
      error_message = Script.select(:message).find_by(name: "password_prompt_invalid", language: "english").message
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

    it "should render results and create a delivery" do
      # XXX Should use factories to setup fake visit and results.
      visit = Visit.create({
        patient_number: rand(10),
        clinic_id: (Clinic.first).id,
        visited_on: Time.now,
        username: rand(1000000000..99999999999).to_s,
        password: rand(1000000000..99999999999).to_s
      })

      # Set our session.
      session = {"visit_id" => visit.id, "language" => "english"}

      # Request our results.
      get(:deliver_results, { :format => :xml }, session)
      expect(response).to have_http_status(:success) # 200
      expect(response).to render_template(:deliver_results)
      expect(response.headers["Content-Type"]).to eq "application/xml; charset=utf-8"

      # XXX Validate the correct message was received (refactor message calculation to model
      # so that we do not hard code it again here).
      expect(assigns(:message)).to_not be_nil

      # XXX Test a delivery entry was made
    end

  end

end