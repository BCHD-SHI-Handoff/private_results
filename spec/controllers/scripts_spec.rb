require 'rails_helper'

describe ScriptsController, :type => :controller do
  before :each do
    @user = User.first
    sign_in @user
  end

  describe "index" do
    it "should set scripts to all of the scripts" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expect(assigns(:scripts)).to eq Script.all
    end
  end

  describe "new" do
    it "should set script to a new script instance" do
      xhr :get, :new, format: :js, test_id: Test.first.id
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
      expect(assigns(:script).id).to be_nil
      expect(assigns(:script).test_id).to eq Test.first.id
    end
  end

  describe "create" do
    it "should create and set script and return flash notice" do
      script = {
        test_id: Test.first.id,
        status_id: Status.first.id,
        language: "fake language",
        message: "new script message"
      }
      xhr :get, :create, format: :js, script: script
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:create)
      expect(assigns(:script).test_id).to eq script[:test_id]
      expect(assigns(:script).status_id).to eq script[:status_id]
      expect(assigns(:script).language).to eq script[:language]
      expect(assigns(:script).message).to eq script[:message]
      expect(flash[:success]).to eq "Successfully added #{Script.find(assigns(:script).id).description}"
    end
  end

  describe "update" do
    it "should update script code" do
      script = Script.first
      xhr :get, :update, id: script.id, format: :js, script: {message: "foobar"}
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:update)
      expect(script.reload.message).to eq "foobar"
      expect(flash[:success]).to eq "Successfully updated #{script.description}"
    end
  end

  describe "destroy" do
    it "should destroy script and return flash notice" do
      script = Script.first
      xhr :get, :destroy, id: script.id, format: :js
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:destroy)
      expect(flash[:success]).to eq "Successfully removed #{script.description}"
    end
  end
end
