require "rails_helper"

describe "dashboard" do
  before :each do
    active_user = create(:user, active: true)
    login_as(active_user, :scope => :user)
    visit root_path
  end

  it "should show dashboard" do
    expect(current_path.to_s).to match root_path
    expect(page).to have_text("Results Delivered")
    expect(page).to have_selector('.label', count: 9)
  end
end