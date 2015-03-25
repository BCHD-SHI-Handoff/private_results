require 'rails_helper'

describe "twilio API" do
  def expect_say(call, message)
    expect(call).to have_say(message), "Expected Say:\n#{message}\nIn Response XML:\n#{call.response_xml}"
  end

  describe "welcome prompt" do
    before :each do
      @call = ttt_call(api_welcome_path, nil, nil, options = {method: :get})
    end

    it "should say welcome message and prompt for language selection" do
      expect_say(@call, get_message("welcome"))
      @call.within_gather do |gather|
        expect_say(gather, "For English, press 1")
        expect_say(gather, "Para Español oprima numero 2")
      end
    end

    it "should repeat welcome with error when no language selected" do
     expect(@call.has_redirect_to?("/api/welcome_repeat.xml")).to eq true
     @call.follow_redirect!
     expect_say(@call, get_message("language_not_selected"))
    end

    it "should repeat welcome with error when invalid language selected" do
      @call.within_gather do |gather|
        gather.press "9"
        expect(@call.current_path).to eq api_welcome_process_path
        expect_say(@call, get_message("language_not_selected"))
      end
    end

    # XXX Twilio-test-toolkit does not properly handle redirects.
    # it "should redirect to username prompt when language selected" do
    #   @call.within_gather do |gather|
    #     gather.press "1"
    #     expect(@call.current_path).to eq username_prompt_path
    #   end
    # end

  end

  describe "username prompt" do
    before :each do
      page.set_rack_session(language: "english")
      @call = ttt_call(api_username_prompt_path, nil, nil, options = {method: :get})
    end

    it "should prompt for username" do
      @call.within_gather do |gather|
        expect_say(gather, get_message("username_prompt"))
      end
    end

    it "should repeat username prompt with error when no username given" do
     expect(@call.has_redirect_to?("/api/username_prompt_repeat.xml")).to eq true
     @call.follow_redirect!
     expect_say(@call, get_message("username_prompt_repeat"))
    end

    it "should repeat username prompt with error when invalid username is given" do
      @call.within_gather do |gather|
        gather.press "9#"
        expect(@call.current_path).to eq api_username_prompt_process_path
        expect_say(@call, get_message("username_prompt_invalid").gsub("{{ username }}", "9"))
      end
    end

    # XXX Twilio-test-toolkit does not properly handle redirects.
    # it "should redirect to password prompt when username is valid" do
    # end
  end

  describe "password prompt" do
    before :each do
      @visit = create(:visit)
      page.set_rack_session(language: "english")
      page.set_rack_session(username: @visit.username)
      @call = ttt_call(api_password_prompt_path, nil, nil, options = {method: :get})
    end

    it "should prompt for password" do
      @call.within_gather do |gather|
        expect_say(gather, get_message("password_prompt"))
      end
    end

    it "should repeat password prompt with error when no password given" do
     expect(@call.has_redirect_to?("/api/password_prompt_repeat.xml")).to eq true
     @call.follow_redirect!
     expect_say(@call, get_message("password_prompt_repeat"))
    end

    it "should repeat password prompt with error when invalid password is given" do
      @call.within_gather do |gather|
        gather.press "9#"
        expect(@call.current_path).to eq api_password_prompt_process_path
        puts 
        message = get_message("password_prompt_invalid")
          .gsub("{{ password }}", "9")
          .gsub("{{ username }}", space_number(@visit.username))
        expect_say(@call, message)
      end
    end

    # XXX Twilio-test-toolkit does not properly handle redirects.
    # it "should redirect to deliver results when password is valid" do
    # end
  end

  describe "deliver results" do
    before :each do
      visit = create(:visit_with_results)
      page.set_rack_session(language: "english")
      page.set_rack_session(visit_id: visit.id)
      @call = ttt_call(api_deliver_results_path, nil, nil, options = {method: :get})
      @message = visit.get_results_message(get_message("master"), "english")
    end

    it "should deliver results" do
      expect_say(@call, @message)
    end

    it "should repeat results" do
     expect(@call.has_redirect_to?("/api/repeat_message.xml")).to eq true
     @call.follow_redirect!
     expect_say(@call, @message)
    end
  end
end
