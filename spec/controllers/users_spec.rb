require 'rails_helper'

describe UsersController, :type => :controller do
  before :each do
    @user = User.first
    sign_in @user
  end

  describe "index" do
    it "should set users to all of the users" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expect(assigns(:users)).to eq User.all
    end
  end

  describe "new" do
    it "should set user to a new user instances" do
      xhr :get, :new, format: :js
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
      expect(assigns(:user).id).to be_nil
      expect(assigns(:user).email).to eq ""
    end
  end

  describe "create" do
    it "should create and set user and return flash notice" do
      xhr :get, :create, format: :js, user: {email: "123fake@example.com", role: "admin"}
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:create)
      expect(assigns(:user).email).to eq "123fake@example.com"
      expect(assigns(:user).role).to eq "admin"
      expect(assigns(:user).active).to eq true
      expect(flash[:success]).to eq "Email sent to '123fake@example.com'"

    end
  end

  describe "update" do
    it "should update active status" do
      xhr :get, :update, id: @user.id, format: :js, user: {active: "false"}
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:update)
      expect(User.first.active).to eq false
      expect(flash[:success]).to eq "Successfully deactivated '#{@user.email}'"
    end

    it "should update role" do
      xhr :get, :update, id: @user.id, format: :js, user: {role: "staff"}
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:update)
      expect(User.first.role).to eq "staff"
      expect(flash[:success]).to eq "Successfully updated '#{@user.email}'"
    end
  end

  describe "destroy" do
    it "should destroy user and return flash notice" do
      xhr :get, :destroy, id: @user.id, format: :js
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:destroy)
      expect(flash[:success]).to eq "'#{@user.email}' has been removed"
    end
  end

  describe "send_reset_password" do
    it "should send password instructions and return flash notice" do
      xhr :get, :send_reset_password, id: @user.id, format: :js
      expect(response).to have_http_status(:success)
      expect(response.body).to be_blank
      expect(ActionMailer::Base.deliveries.last.to.first).to eq @user.email
      expect(ActionMailer::Base.deliveries.last.subject).to eq "Reset password instructions"
      expect(flash[:success]).to eq "Reset password instructions send to '#{@user.email}'"
    end
  end
end
