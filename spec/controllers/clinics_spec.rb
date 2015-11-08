require 'rails_helper'

describe ClinicsController, :type => :controller do
  before :each do
    @user = User.first
    sign_in @user
  end

  describe "index" do
    it "should set clinics to all of the clinics" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expect(assigns(:clinics)).to eq Clinic.all
    end
  end

  describe "new" do
    it "should set clinic to a new clinic instance" do
      xhr :get, :new, format: :js
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
      expect(assigns(:clinic).id).to be_nil
      expect(assigns(:clinic).name).to be_nil
      expect(assigns(:clinic).hours_in_english).to eq "Monday to Friday, 9am to 5pm"
      expect(assigns(:clinic).hours_in_spanish).to eq "Lunes a Viernes, 9am a 5pm"
    end
  end

  describe "create" do
    it "should create and set clinic and return flash notice" do
      clinic = {
        name: "Fake Clinic",
        code: "F",
        hours_in_english: "All day",
        hours_in_spanish: "Todo el dia"
      }
      xhr :get, :create, format: :js, clinic: clinic
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:create)
      expect(assigns(:clinic).name).to eq clinic[:name]
      expect(assigns(:clinic).code).to eq clinic[:code]
      expect(assigns(:clinic).hours_in_english).to eq clinic[:hours_in_english]
      expect(assigns(:clinic).hours_in_spanish).to eq clinic[:hours_in_spanish]
      expect(flash[:success]).to eq "Successfully added '#{clinic[:name]}'"
    end
  end

  describe "update" do
    it "should update clinic code" do
      clinic = Clinic.first
      xhr :get, :update, id: clinic.id, format: :js, clinic: {name: "New Clinic Name"}
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:update)
      expect(clinic.reload.name).to eq "New Clinic Name"
      expect(flash[:success]).to eq "Successfully updated '#{clinic.name}'"
    end
  end

  describe "destroy" do
    it "should destroy clinic and return flash notice" do
      clinic = Clinic.first
      xhr :get, :destroy, id: clinic.id, format: :js
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:destroy)
      expect(flash[:success]).to eq "'#{clinic.name}' has been removed"
    end
  end
end
