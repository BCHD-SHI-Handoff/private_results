require "rails_helper"

describe "dashboard" do
  before :each do
    active_user = create(:user, active: true)
    login_as(active_user, :scope => :user)
    visit dashboards_path
  end

  it "should show dashboard" do
    expect(current_path.to_s).to match dashboards_path
    expect(page).to have_text("\"Pending\" Results")
    expect(page).to have_selector('td', count: 21)
  end
end