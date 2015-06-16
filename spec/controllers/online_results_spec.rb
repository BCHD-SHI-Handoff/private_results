require 'rails_helper'

describe OnlineResultsController, :type => :controller do
  describe "index" do
    it "should render main page" do
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end
  end

  describe "show" do
    it "should get message with valid username and password" do
      v = create(:visit_with_results)
      expect(Delivery.all.length).to eq 0
      xhr :post, :show, {username: v.username, password: v.password}, format: :js
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
      expect(Delivery.all.length).to eq 1
      delivery = Delivery.first
      expect(assigns(:message)).to eq delivery.message
      expect(delivery.delivery_method).to eq "online"
    end

    it "should get flash message with invalid username and password" do
      v = create(:visit_with_results)
      expect(Delivery.all.length).to eq 0
      xhr :post, :show, {username: "12345", password: "55555"}, format: :js
      expect(assigns(:username)).to eq "12345"
      expect(assigns(:password)).to eq "55555"
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
      expect(flash[:alert]).to eq "The password does not match the username that you provided. If you think this is an error, please contact the clinic."
    end
  end
end
