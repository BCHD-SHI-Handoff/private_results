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
  end

  it "should be able to activate/deactivate accounts", :js => true do
    admin_row = find("tr[data-user-id='1']")
    within admin_row do
      expect(page).to have_text(DEFAULT_USER_EMAIL)
      page.click_button "Deactivate"
    end

    # # Reload the tr as the update would have cleared the tr.
    # admin_row = find("tr[data-user-id='1']")
    # within admin_row do
    #   expect(page.find(".growlyflash")).to have_text("Successfully deactivated '#{DEFAULT_USER_EMAIL}'")
    #   expect(page.find(".label-warning")).to have_text("Inactive")
    #   click_button "Activate"
    # end

    # # Reload the tr as the update would have cleared the tr.
    # admin_row = find("tr[data-user-id='1']")
    # within admin_row do
    #   expect(page.find(".label-info")).to have_text("Active")
    #   expect(page.find(".growlyflash")).to have_text("Successfully activated '#{DEFAULT_USER_EMAIL}'")
    # end
  end

  it "should be able to edit accounts" do
  end

  it "should be able to delete accounts" do
  end

  it "should be able to reset password" do
  end

  it "should be able to create new users" do
  end
end