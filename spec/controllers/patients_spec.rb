require 'rails_helper'

describe PatientsController, :type => :controller do
  before :each do
    @user = User.first
    sign_in @user
  end

  describe "index" do
    it "should set visits and patient_number to nil and render patients" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:patients)
      expect(assigns(:patient_number)).to be_nil
      expect(assigns(:visits)).to be_nil
    end

    it "should set visits and patient_number when provided patient number" do
      # Create some visits with results for patient 33 and 3333.
      create(:visit_with_results, patient_number: "33")
      create(:visit_with_results, patient_number: "3333")
      create(:visit_with_results, patient_number: "33")
      create(:visit_with_results, patient_number: "33")
      create(:visit_with_results, patient_number: "3333")

      # Get patient number 33.
      get :index, patient_number: "33"
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:patients)
      expect(assigns(:patient_number)).to eq "33"
      expect(assigns(:visits).length).to eq 3
    end

  end
end
