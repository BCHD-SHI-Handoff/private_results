require "rails_helper"

describe "scripts" do
  before :each do
    @admin_user = create(:user, active: true, role: :admin)
    login_as(@admin_user, :scope => :user)
    visit scripts_path
    click_link "Test Scripts"
  end

  it "should not be visible to non admins", skip_before: true do
    staff_user = create(:user, active: true, role: :staff)
    login_as(staff_user, :scope => :user)
    visit scripts_path
    expect(current_path.to_s).to_not match scripts_path
    expect(current_path.to_s).to match dashboards_path
    expect(page).to_not have_link("Scripts")
  end

  it "should show all scripts somewhere on page" do
    expect(current_path.to_s).to match scripts_path
    expect(page).to have_link("Scripts")
    expect(page).to have_selector(".script", count: Script.all.length)
  end

  it "should be able to edit scripts", :js => true do
    # Grab a script for our first test.
    script = Script.where(test: Test.first).first
    script_row = find("tr[data-script-id='#{script.id}']")
    within script_row do
      page.click_button "Edit"
    end

    modal = find("div.modal-content")
    within modal do
      expect(page).to have_select('script[status_id]', selected: script.status.status)
      expect(find_field("script_language_english")).to be_checked
      expect(page).to have_field("script[message]", :with => script.message)
      fill_in "script[message]", with: "new message"
      page.click_button "Save script"
    end

    expect(page.find(".growlyflash")).to have_text("Successfully updated #{script.reload.description}")
    expect(script.message).to eq "new message"
  end

  it "should be able to create new scripts", js: true do
    click_button "New"
    modal = find("div.modal-content")
    within modal do
      select "Negative", :from => "script[status_id]"
      choose("spanish")
      fill_in "script[message]", with: "new message"
      click_button('Create script')
    end

    # Not including #{script.description} below because the message may appear before
    # we can retrieve it from the DB (so we wouldn't easily have a script model on hand yet).
    expect(page.find(".growlyflash")).to have_text("Successfully added")
    expect(Script.last.message).to eq "new message"
  end

  it "should be able to delete scripts", :js => true do
    # Grab a script for our first test.
    script = Script.where(test: Test.first).first
    script_row = find("tr[data-script-id='#{script.id}']")
    within script_row do
      find("button.btn-danger").click
      # page.driver.browser.switch_to.alert.accept # Needed if using chrome driver
    end

    expect(page.find(".growlyflash")).to have_text("Successfully removed #{script.description}")
    expect(Script.find_by_id(script.id)).to be_nil
  end
end