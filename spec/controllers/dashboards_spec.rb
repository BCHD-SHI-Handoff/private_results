require 'rails_helper'

describe DashboardsController, :type => :controller do
  before :each do
    @user = User.first
    sign_in @user
  end

  describe "index" do
    it "should set dashboard and render dashboard when zero visits" do
      get :index
      expect(response).to have_http_status(:success) # 200
      expect(response).to render_template(:dashboard)
      expected_dashboard = {
        results_delivered: {
          last_30_days: 0,
          last_3_months: 0,
          last_12_months: 0
        },
        percentage_delivered: {
          last_30_days: 0,
          last_3_months: 0,
          last_12_months: 0
        },
        visits: {
          last_30_days: 0,
          last_3_months: 0,
          last_12_months: 0
        }
      }
      expect(assigns(:dashboard)).to eq expected_dashboard
    end

    it "should set dashboard and render dashboard when real visits" do
      # Setup 6 visits: 2 within 30 days, 1 within 3 months, 2 within 12 months and 1 over 12 months.
      visit1_within_30_days = create(:visit_with_results, results_count: 1, visited_on: 5.days.ago)
      visit2_within_30_days = create(:visit_with_results, results_count: 1, visited_on: 25.days.ago)
      visit1_within_3_months = create(:visit_with_results, results_count: 1, visited_on: 2.months.ago)
      visit1_within_12_months = create(:visit_with_results, results_count: 1, visited_on: 7.months.ago)
      visit2_within_12_months = create(:visit_with_results, results_count: 6, visited_on: 11.months.ago)
      visit1_over_12_months = create(:visit_with_results, results_count: 1, visited_on: 14.months.ago)

      # Setup delivery for a visit within 30 days.
      visit1_within_30_days_delivery = create(:delivery)
      visit1_within_30_days.results.each do |result|
        result.deliveries << visit1_within_30_days_delivery
      end

      # Setup delivery for a visit within 12 months.
      visit2_within_12_months_delivery = create(:delivery)
      visit2_within_12_months.results.each do |result|
        result.deliveries << visit2_within_12_months_delivery
      end

      get :index
      expect(response).to have_http_status(:success) # 200
      expect(response).to render_template(:dashboard)
      expected_dashboard = {
        results_delivered: {
          last_30_days: 1,
          last_3_months: 1,
          last_12_months: 7
        },
        percentage_delivered: {
          last_30_days: 50,
          last_3_months: 33,
          last_12_months: 70
        },
        visits: {
          last_30_days: 2,
          last_3_months: 3,
          last_12_months: 5
        }
      }
      expect(assigns(:dashboard)).to eq expected_dashboard
    end

  end
end
