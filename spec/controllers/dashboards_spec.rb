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
        visits: {
          last_30_days: 0,
          last_3_months: 0,
          last_12_months: 0
        },
        online_visits: {
          last_30_days: 0,
          last_3_months: 0,
          last_12_months: 0
        },
        call_ins: {
          last_30_days: 0,
          last_3_months: 0,
          last_12_months: 0
        },
      }
      expect(assigns(:dashboard)).to eq expected_dashboard
    end

    it "should set dashboard and render dashboard when real visits" do
      # Setup 6 visits: 3 within 30 days, 1 within 3 months, 2 within 12 months and 1 over 12 months.
      visit1_within_30_days = create(:visit, visited_on: 5.days.ago)
      visit2_within_30_days = create(:visit, visited_on: 25.days.ago)
      visit3_within_30_days = create(:visit, visited_on: 25.days.ago)
      visit1_within_3_months = create(:visit, visited_on: 2.months.ago)
      visit1_within_12_months = create(:visit, visited_on: 7.months.ago)
      visit2_within_12_months = create(:visit, visited_on: 11.months.ago)
      visit1_over_12_months = create(:visit, visited_on: 14.months.ago)

      # Now comes the hard part. We want to setup many results. We also want
      # to replicate the possibility of several results coming in for the same visit/test combo.
      # The dashboard should be smart enought to take only the LATEST result record for
      # visit/test combos. So if there was a result for chlamydia as pending but then later another
      # result came in for the same visit & test as negative, it would be counted as only 1 results_in and 0 for pending.

      pending_id = Status.find_by_status("Pending").id
      come_back_id = Status.find_by_status("Come back to clinic").id
      negative_id = Status.find_by_status("Negative").id

      chlamydia_id = Test.find_by_name("Chlamydia").id
      syphilis_id = Test.find_by_name("Syphilis").id

      not_delivered = Result.delivery_statuses[:not_delivered]
      delivered = Result.delivery_statuses[:delivered]
      come_back = Result.delivery_statuses[:come_back]

      # Setup some results and mark some as delivered.
      # visit1_within_30_days has several results but ultimately leads to 2 negative, 2 delivered
      visit1_within_30_days.results.create(test_id: chlamydia_id, status_id: pending_id, recorded_on: 2.days.ago)
      visit1_within_30_days.results.create(test_id: syphilis_id, status_id: pending_id, recorded_on: 2.days.ago)
      visit1_within_30_days.results.create(test_id: chlamydia_id, status_id: pending_id, recorded_on: 1.days.ago)
      visit1_within_30_days.results.create(test_id: syphilis_id, status_id: negative_id, recorded_on: 1.days.ago, delivery_status: delivered)
      visit1_within_30_days.results.create(test_id: chlamydia_id, status_id: negative_id, recorded_on: Time.now, delivery_status: delivered)
      visit1_within_30_days.results.create(test_id: syphilis_id, status_id: negative_id, recorded_on: Time.now, delivery_status: delivered)

      # visit2_within_30_days has 2 pendings
      visit2_within_30_days.results.create(test_id: chlamydia_id, status_id: pending_id, recorded_on: 1.days.ago)
      visit2_within_30_days.results.create(test_id: syphilis_id, status_id: pending_id, recorded_on: 1.days.ago)
      visit2_within_30_days.results.create(test_id: chlamydia_id, status_id: pending_id, recorded_on: Time.now, delivery_status: not_delivered)
      visit2_within_30_days.results.create(test_id: syphilis_id, status_id: pending_id, recorded_on: Time.now, delivery_status: not_delivered)

      # visit3_within_30_days has 1 pending and 1 come_back
      visit3_within_30_days.results.create(test_id: chlamydia_id, status_id: pending_id, recorded_on: 1.days.ago)
      visit3_within_30_days.results.create(test_id: syphilis_id, status_id: come_back_id, recorded_on: 1.days.ago)
      visit3_within_30_days.results.create(test_id: chlamydia_id, status_id: pending_id, recorded_on: Time.now)
      visit3_within_30_days.results.create(test_id: syphilis_id, status_id: come_back_id, recorded_on: Time.now, delivery_status: come_back)

      # visit1_within_3_months has 1 pending and 1 come_back
      visit1_within_3_months.results.create(test_id: chlamydia_id, status_id: pending_id, recorded_on: 1.days.ago)
      visit1_within_3_months.results.create(test_id: syphilis_id, status_id: pending_id, recorded_on: 1.days.ago)
      visit1_within_3_months.results.create(test_id: chlamydia_id, status_id: pending_id, recorded_on: Time.now)
      visit1_within_3_months.results.create(test_id: syphilis_id, status_id: come_back_id, recorded_on: Time.now)

      # visit1_within_12_months has 2 negative, 1 delivered
      visit1_within_12_months.results.create(test_id: chlamydia_id, status_id: negative_id, recorded_on: 1.days.ago, delivery_status: delivered)
      visit1_within_12_months.results.create(test_id: syphilis_id, status_id: negative_id, recorded_on: 1.days.ago)
      visit1_within_12_months.results.create(test_id: chlamydia_id, status_id: negative_id, recorded_on: Time.now, delivery_status: delivered)
      visit1_within_12_months.results.create(test_id: syphilis_id, status_id: negative_id, recorded_on: Time.now)

      # visit2_within_12_months has 2 corrupt statuses
      visit2_within_12_months.results.create(test_id: syphilis_id, status_id: nil, recorded_on: 1.days.ago)
      visit2_within_12_months.results.create(test_id: chlamydia_id, status_id: nil, recorded_on: 1.days.ago)
      visit2_within_12_months.results.create(test_id: syphilis_id, status_id: nil, recorded_on: Time.now)
      visit2_within_12_months.results.create(test_id: chlamydia_id, status_id: nil, recorded_on: Time.now)

      # visit1_over_12_months has 1 pending and 1 negative
      visit1_over_12_months.results.create(test_id: chlamydia_id, status_id: negative_id, recorded_on: Time.now, delivery_status: delivered)
      visit1_over_12_months.results.create(test_id: syphilis_id, status_id: pending_id, recorded_on: Time.now)

      # Setup deliveries
      create(:delivery, delivery_method: 'phone', delivered_at: 5.days.ago)
      create(:delivery, delivery_method: 'online', delivered_at: 15.days.ago)
      create(:delivery, delivery_method: 'online', delivered_at: 25.days.ago)

      create(:delivery, delivery_method: 'phone', delivered_at: 2.months.ago)
      create(:delivery, delivery_method: 'online', delivered_at: 2.months.ago)

      create(:delivery, delivery_method: 'online', delivered_at: 4.months.ago)
      create(:delivery, delivery_method: 'phone', delivered_at: 4.months.ago)
      create(:delivery, delivery_method: 'phone', delivered_at: 5.months.ago)
      create(:delivery, delivery_method: 'phone', delivered_at: 10.months.ago)

      get :index
      expect(response).to have_http_status(:success) # 200
      expect(response).to render_template(:dashboard)
      expected_dashboard = {
        visits: {
          last_30_days: 3,
          last_3_months: 4,
          last_12_months: 6
        },
        online_visits: {
          last_30_days: 2,
          last_3_months: 3,
          last_12_months: 4
        },
        call_ins: {
          last_30_days: 1,
          last_3_months: 2,
          last_12_months: 5
        },
      }
      expect(assigns(:dashboard)).to eq expected_dashboard
    end
  end
end
