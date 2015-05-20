require "rails_helper"

describe "clinics" do
  before :each do
    @admin_user = create(:user, active: true, role: :admin)
    login_as(@admin_user, :scope => :user)
    visit clinics_path
  end

  it "should not be visible to non admins", skip_before: true do
    staff_user = create(:user, active: true, role: :staff)
    login_as(staff_user, :scope => :user)
    visit clinics_path
    expect(current_path.to_s).to_not match clinics_path
    expect(current_path.to_s).to match dashboards_path
    expect(page).to_not have_link("Clinics")
  end

  it "should show existing clinics" do
    expect(current_path.to_s).to match clinics_path
    expect(page).to have_link("Clinics")
    expect(page).to have_selector(".clinic", count: Clinic.all.length)
    expect(page).to have_text(Clinic.first.name)
  end

  it "should be able to edit clinics", :js => true do
    clinic = Clinic.first
    clinic_row = find("tr[data-clinic-id='#{clinic.id}']")
    within clinic_row do
      page.click_button "Edit"
    end

    modal = find("div.modal-content")
    within modal do
      have_field("clinic[name]", :with => clinic.name)
      have_field("clinic[code]", :with => clinic.code)
      have_field("clinic[hours_in_english]", :with => clinic.hours_in_english)
      have_field("clinic[hours_in_spanish]", :with => clinic.hours_in_spanish)
    end

    # We don't actually edit the clinic here as clincis are persisted across tests.
  end

  it "should be able to create new clinics", js: true do
    click_button "New"
    modal = find("div.modal-content")
    within modal do
      fill_in "clinic_name", with: Clinic.first.name
      fill_in "clinic_code", with: Clinic.first.code
      click_button('Create clinic')
    end

    expect(page).to have_text("has already been taken")

    # We don't actually createa a new clinic here as clincis are persisted across tests.
  end
end