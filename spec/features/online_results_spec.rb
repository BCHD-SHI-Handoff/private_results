require "rails_helper"

describe "online_results" do

  before :each do
    visit root_path
  end

  let(:clinic_visit) { create(:visit_with_results) }

  it "should successfully get result message" do
    fill_in "username", :with => clinic_visit.username
    fill_in "password", :with => clinic_visit.password
    click_button "Submit"
    expect(current_path.to_s).to match results_path
    delivery = Delivery.first
    expect(page).to have_text(delivery.message)
  end
end
