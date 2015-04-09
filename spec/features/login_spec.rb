# Test all of the actions a non signed in user can perform,
# this includes signing in, reset lost password, resend email confirmation,
# resend unlock instructions.
#
# Note, we use I18n.t to use the strings inside devise.yml as appose to copying
# and hardcoding the strings again here.
require "rails_helper"

describe "accounts" do

  let(:inactive_user) { create(:user, active: false) }
  let(:uncofirmed_user) { create(:user, confirmed_at: nil) }
  let(:locked_user) { create(:user, locked_at: Time.now, unlock_token: "dummy_token") }
  let(:invalid_email) { "invalid@example.com" }

  describe "login" do
    before :each do
      visit root_path
    end

    it "should successfully login with #{DEFAULT_USER_EMAIL}" do 
      expect(current_path.to_s).to match new_user_session_path
      fill_in "user_email", :with => DEFAULT_USER_EMAIL
      fill_in "user_password", :with => DEFAULT_USER_PASSWORD
      click_button "Log in"
      expect(current_path.to_s).to match root_path
      expect(page.find(".alert-info")).to have_text(I18n.t("devise.sessions.signed_in"))
    end

    it "should fail to login with invalid user" do 
      fill_in "user_email", :with => invalid_email
      fill_in "user_password", :with => "bad_pass"
      click_button "Log in"
      expect(current_path.to_s).to match new_user_session_path
      expect(page.find(".alert-warning")).to have_text(I18n.t("devise.failure.invalid", authentication_keys: "email"))
    end

    it "should fail to login with inactive user" do 
      fill_in "user_email", :with => inactive_user.email
      fill_in "user_password", :with => DEFAULT_USER_PASSWORD
      click_button "Log in"
      expect(current_path.to_s).to match new_user_session_path
      expect(page.find(".alert-warning")).to have_text(I18n.t("devise.failure.inactive"))
    end

    it "should fail for users without confirmed emails" do
      fill_in "user_email", :with => uncofirmed_user.email
      fill_in "user_password", :with => DEFAULT_USER_PASSWORD
      click_button "Log in"
      expect(current_path.to_s).to match new_user_session_path
      expect(page.find(".alert-warning")).to have_text(I18n.t("devise.failure.unconfirmed"))
    end
  end

  describe "forgot your password" do
    it "should send password reset email" do
      # Click forgot passowrd link on login page.
      visit root_path
      click_link "Forgot your password?"
      expect(current_path.to_s).to match new_user_password_path

      # Fill in email and click submit.
      fill_in "user_email", :with => DEFAULT_USER_EMAIL
      click_button "Reset Password"

      # Check email was sent and we got the proper result.
      expect(last_email.to.first).to eq DEFAULT_USER_EMAIL
      expect(last_email.subject).to eq I18n.t("devise.mailer.reset_password_instructions.subject")
      expect(page.find(".alert-info")).to have_text(I18n.t("devise.passwords.send_instructions"))
      expect(current_path.to_s).to match new_user_session_path
    end

    it "should show email not found error" do
      visit new_user_password_path
      fill_in "user_email", :with => invalid_email
      click_button "Reset Password"
      expect(page.find(".alert-danger")).to have_text("Email " + I18n.t("errors.messages.not_found"))
      expect(current_path.to_s).to match user_password_path
    end
  end

  describe "resend confirmation email" do
    it "should send confirmation email again" do
      # Click confirmation instruction link on login page.
      visit root_path
      click_link "Didn't receive confirmation instructions?"
      expect(current_path.to_s).to match new_user_confirmation_path

      # Fill in email and click submit.
      fill_in "user_email", :with => uncofirmed_user.email
      click_button "Resend confirmation instructions"

      # Check email was sent and we got the proper result.
      expect(last_email.to.first).to eq uncofirmed_user.email
      expect(last_email.subject).to eq I18n.t("devise.mailer.confirmation_instructions.subject")
      expect(page.find(".alert-info")).to have_text(I18n.t("devise.confirmations.send_instructions"))
      expect(current_path.to_s).to match new_user_session_path
    end

    it "should notify when email already confirmed" do
      visit new_user_confirmation_path
      fill_in "user_email", :with => DEFAULT_USER_EMAIL
      click_button "Resend confirmation instructions"
      expect(page.find(".alert-danger")).to have_text("Email " + I18n.t("errors.messages.already_confirmed"))
      expect(current_path.to_s).to match user_confirmation_path
    end

    it "should show email not found error" do
      visit new_user_confirmation_path
      fill_in "user_email", :with => invalid_email
      click_button "Resend confirmation instructions"
      expect(page.find(".alert-danger")).to have_text("Email " + I18n.t("errors.messages.not_found"))
      expect(current_path.to_s).to match user_confirmation_path
    end
  end

  describe "resend unlock instructions" do
    it "should send unlock instructions again" do
      # Click unlock instruction link on login page.
      visit root_path
      click_link "Didn't receive unlock instructions?"
      expect(current_path.to_s).to match new_user_unlock_path

      # Fill in email and click submit.
      fill_in "user_email", :with => locked_user.email
      click_button "Resend unlock instructions"

      # Check email was sent and we got the proper result.
      expect(last_email.to.first).to eq locked_user.email
      expect(last_email.subject).to eq I18n.t("devise.mailer.unlock_instructions.subject")
      expect(page.find(".alert-info")).to have_text(I18n.t("devise.unlocks.send_instructions"))
      expect(current_path.to_s).to match new_user_session_path
    end

    it "should notify when email not locked" do
      visit new_user_unlock_path
      fill_in "user_email", :with => DEFAULT_USER_EMAIL
      click_button "Resend unlock instructions"
      expect(page.find(".alert-danger")).to have_text("Email " + I18n.t("errors.messages.not_locked"))
      expect(current_path.to_s).to match user_unlock_path
    end

    it "should show email not found error" do
      visit new_user_unlock_path
      fill_in "user_email", :with => invalid_email
      click_button "Resend unlock instructions"
      expect(page.find(".alert-danger")).to have_text("Email " + I18n.t("errors.messages.not_found"))
      expect(current_path.to_s).to match user_unlock_path
    end
  end

end