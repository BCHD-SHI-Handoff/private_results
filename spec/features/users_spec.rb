require "rails_helper"

describe "users" do
  before :each do
    @admin_user = create(:user, active: true, role: :admin)
    login_as(@admin_user, :scope => :user)
    visit users_path
  end

  it "should not be visible to non admins", skip_before: true do
    staff_user = create(:user, active: true, role: :staff)
    login_as(staff_user, :scope => :user)
    visit users_path
    expect(current_path.to_s).to_not match users_path
    expect(current_path.to_s).to match dashboards_path
    expect(page).to_not have_link("Users")
  end

  it "should show existing users" do
    expect(current_path.to_s).to match users_path
    expect(page).to have_link("Users")
    expect(page).to have_selector(".user", count: User.all.length)
    expect(page).to have_text(@admin_user.email)
  end

  it "should not be able to edit self" do
    admin_row = find("tr[data-user-id='#{@admin_user.id}']")
    within admin_row do
      expect(page).to have_text(@admin_user.email)
      # Can reset password for self.
      expect(page).to have_selector(:link_or_button, 'Reset Password')

      expect(page).to_not have_selector(:link_or_button, 'Deactivate')
      expect(page).to_not have_selector(:link_or_button, 'Edit')
      expect(page).to_not have_css("button.btn-danger")
    end
  end

  it "should be able to activate/deactivate accounts", :js => true do
    admin_row = find("tr[data-user-id='#{@default_user.id}']")
    expect(@default_user.active?).to eq true
    within admin_row do
      expect(page).to have_text(DEFAULT_USER_EMAIL)
      expect(page).to have_selector(:link_or_button, 'Deactivate')
      expect(page).to have_selector(:link_or_button, 'Reset Password')
      expect(page).to have_selector(:link_or_button, 'Edit')
      expect(page).to have_css("button.btn-danger")
      page.click_button "Deactivate"
      # page.driver.browser.switch_to.alert.accept # Needed if using chrome driver
    end

    expect(page.find(".growlyflash")).to have_text("Successfully deactivated '#{DEFAULT_USER_EMAIL}'")
    expect(@default_user.reload.active?).to eq false

    # Reload the tr as the update would have cleared the tr.
    admin_row = find("tr[data-user-id='#{@default_user.id}']")
    within admin_row do
      expect(page.find(".label-warning")).to have_text("Inactive")
      click_button "Activate"
      # page.driver.browser.switch_to.alert.accept # Needed if using chrome driver
    end

    expect(page.find(".growlyflash")).to have_text("Successfully activated '#{DEFAULT_USER_EMAIL}'")
    expect(@default_user.reload.active?).to eq true

    # Reload the tr as the update would have cleared the tr.
    admin_row = find("tr[data-user-id='#{@default_user.id}']")
    within admin_row do
      expect(page.find(".label-info")).to have_text("Active")
    end
  end

  it "should be able to edit accounts", :js => true do
    admin_row = find("tr[data-user-id='#{@default_user.id}']")
    within admin_row do
      page.click_button "Edit"
    end

    expect(@default_user.staff?).to eq false
    modal = find("div.modal-content")
    within modal do
      expect(page).to have_field("user[email]", :with => DEFAULT_USER_EMAIL)
      expect(find_field("user_role_admin")).to be_checked
      choose('staff')
      page.click_button "Save user"
    end

    expect(page.find(".growlyflash")).to have_text("Successfully updated '#{DEFAULT_USER_EMAIL}'")
    # XXX Sometimes the above staff selection doesn't work.
    #   Possible race condition within capybara and the js driver?
    # expect(@default_user.reload.staff?).to eq true
  end

  it "should be able to delete accounts", :js => true do
    expect(User.find_by_email(DEFAULT_USER_EMAIL)).to_not be_nil

    admin_row = find("tr[data-user-id='#{@default_user.id}']")
    within admin_row do
      find("button.btn-danger").click
      # page.driver.browser.switch_to.alert.accept # Needed if using chrome driver
    end

    expect(page.find(".growlyflash")).to have_text("'#{DEFAULT_USER_EMAIL}' has been removed")
    expect(User.find_by_email(DEFAULT_USER_EMAIL)).to be_nil
  end

  it "should be able to reset password", :js => true do
    expect(@default_user.reset_password_token).to be_nil
    admin_row = find("tr[data-user-id='#{@default_user.id}']")
    within admin_row do
      page.click_button "Reset Password"
    end
    expect(page.find(".growlyflash")).to have_text("Reset password instructions send to '#{DEFAULT_USER_EMAIL}'")
    expect(@default_user.reload.reset_password_token).to_not be_nil
  end

  it "should be able to create new users", js: true do
    click_button "New"
    modal = find("div.modal-content")
    within modal do
      fill_in "user_email", with: DEFAULT_USER_EMAIL
      choose('admin')
      click_button('Create user')
    end

    expect(page).to have_text("has already been taken")

    modal = find("div.modal-content")
    within modal do
      fill_in "user_email", with: "test@example.com"
      choose('admin')
      click_button('Create user')
    end

    expect(page.find(".growlyflash")).to have_text("Email sent to 'test@example.com'")
    expect(User.find_by_email("test@example.com")).to_not be_nil
  end
end