require "rails_helper"

describe "patients" do
  before :each do
    active_user = create(:user, active: true)
    login_as(active_user, :scope => :user)
    visit patients_path
  end

  it "should show patient search" do
    expect(current_path.to_s).to match patients_path
    expect(page).to have_text("Patients")
    expect(page).to have_field('patient_number')
  end

  it "should show error when patient not found" do
    fill_in "patient_number", :with => "invalid"
    click_button "Search"
    expect(page.find(".alert-danger")).to have_text("Patient invalid not found")
  end

  it "should show patient visits" do
    # Create some visits with results for patient 33 and 3333.
    create(:visit_with_results, patient_number: "33")
    create(:visit_with_results, patient_number: "3333")
    create(:visit_with_results, patient_number: "33")
    create(:visit_with_results, patient_number: "33")
    create(:visit_with_results, patient_number: "3333")

    visits = Visit.where(patient_number: '33').order(visited_on: :desc)
    delivery = create(:delivery)
    visits.first.results.first.deliveries << delivery
    visits.first.results.first.save!

    fill_in "patient_number", :with => "33"
    click_button "Search"

    # Should have 3 visits.
    expect(page).to have_selector('.visit', count: 3)

    # First visit should have some results and one delivered.
    within first(".visit") do
      # Check to make sure all of the results show up and one is delivered.
      within first("table") do
        expect(page).to have_selector("tr", count: visits.first.results.length)
        expect(first("tr")).to_not have_text("Not Delivered")
        expect(first("tr")).to have_text("Delivered")
        expect(page).to have_text("Not Delivered", count: visits.first.results.length - 1)
      end

      # Check we get the delivered message.
      within all("table").last do
        expect(page).to have_selector("tr", count: 1)
        expect(page).to have_text(delivery.message)
      end
    end
  end
end