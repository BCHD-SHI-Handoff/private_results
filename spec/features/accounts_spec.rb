# Test all of the actions a non signed in user can perform,
# this includes signing in, reset lost password, resend email confirmation,
# resend unlock instructions.
#
# Note, we use I18n.t to use the strings inside devise.yml as appose to copying
# and hardcoding the strings again here.
require "rails_helper"

describe "accounts" do

  let(:active_user) { create(:user, active: true) }
  let(:inactive_user) { create(:user, active: false) }
  let(:unconfirmed_user) { create(:user, confirmed_at: nil) }
  let(:locked_user) { create(:user, locked_at: Time.now, unlock_token: "dummy_token") }
  let(:invalid_email) { "invalid@example.com" }

  describe "login" do
    before :each do
      visit dashboards_path
    end

    it "should successfully login with #{DEFAULT_USER_EMAIL}" do
      expect(current_path.to_s).to match new_user_session_path
      fill_in "user_email", :with => DEFAULT_USER_EMAIL
      fill_in "user_password", :with => DEFAULT_USER_PASSWORD
      click_button "Log in"
      expect(current_path.to_s).to match dashboards_path
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
      fill_in "user_email", :with => unconfirmed_user.email
      fill_in "user_password", :with => DEFAULT_USER_PASSWORD
      click_button "Log in"
      expect(current_path.to_s).to match new_user_session_path
      expect(page.find(".alert-warning")).to have_text(I18n.t("devise.failure.unconfirmed"))
    end

    it "should successfully logout" do
      login_as(active_user, :scope => :user)
      visit dashboards_path
      click_link "Sign Out"
      expect(current_path.to_s).to match new_user_session_path
      expect(page.find(".alert-warning")).to have_text(I18n.t("devise.failure.unauthenticated"))
    end
  end

  describe "forgot your password" do
    it "should send password reset email" do
      # Click forgot passowrd link on login page.
      visit dashboards_path
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

    it "should be able to reset password" do
      token = active_user.send_reset_password_instructions
      visit "#{edit_user_password_path}?reset_password_token=#{token}"
      fill_in "user_password", :with => DEFAULT_USER_PASSWORD
      fill_in "user_password_confirmation", :with => DEFAULT_USER_PASSWORD
      click_button "Update Password"
      expect(current_path.to_s).to match dashboards_path
      expect(page.find(".alert-info")).to have_text(I18n.t("devise.passwords.updated"))
    end

  end

  describe "confirmation email" do
    it "should send confirmation email again" do
      # Click confirmation instruction link on login page.
      visit dashboards_path
      click_link "Didn't receive email confirmation after creating a new user?"
      expect(current_path.to_s).to match new_user_confirmation_path

      # Fill in email and click submit.
      fill_in "user_email", :with => unconfirmed_user.email
      click_button "Resend confirmation instructions"

      # Check email was sent and we got the proper result.
      expect(last_email.to.first).to eq unconfirmed_user.email
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

    it "should confirm email" do
      # Need to set password to nil in order to get the password form on email confirmation.
      unconfirmed_user2 = create(:user, confirmed_at: nil, password: nil, password_confirmation: nil)
      confirmation_email = unconfirmed_user2.send_confirmation_instructions
      token = confirmation_email.body.to_s[/confirmation_token=([^"]+)/, 1]
      visit "#{user_confirmation_path}?confirmation_token=#{token}"
      expect(page).to have_text("Account Activation for #{unconfirmed_user2.email}")
      fill_in "user_password", :with => DEFAULT_USER_PASSWORD
      fill_in "user_password_confirmation", :with => DEFAULT_USER_PASSWORD
      click_button "Activate"
      expect(page.find(".alert-info")).to have_text(I18n.t("devise.confirmations.confirmed"))
    end
  end

  describe "resend unlock instructions" do
    it "should send unlock instructions again" do
      # Click unlock instruction link on login page.
      visit dashboards_path
      click_link "Didn't receive unlock instructions after getting locked out of your account?"
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

    it "should unlock email" do
      token = locked_user.send_unlock_instructions
      visit "#{user_unlock_path}?unlock_token=#{token}"
      expect(current_path.to_s).to match new_user_session_path
      expect(page.find(".alert-info")).to have_text(I18n.t("devise.unlocks.unlocked"))
    end
  end
end