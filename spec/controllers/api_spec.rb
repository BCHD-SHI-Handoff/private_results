require 'rails_helper'

describe ApiController, :type => :controller do

  describe "deliver_results" do

    it "should render results and create a delivery" do
      # XXX Should use factories to setup fake visit and results.
      visit = Visit.create({
        patient_number: rand(10),
        clinic_id: (Clinic.first).id,
        visited_on: Time.now,
        username: rand(1000000000..99999999999).to_s,
        password: rand(1000000000..99999999999).to_s
      })

      # Set our session.
      session = {"visit_id" => visit.id, "language" => "english"}

      # Request our results.
      get(:deliver_results, { :format => :xml }, session)
      expect(response).to have_http_status(:success) # 200
      expect(response).to render_template(:deliver_results)
      expect(response.headers["Content-Type"]).to eq "application/xml; charset=utf-8"

      # XXX Validate the correct message was received (refactor message calculation to model
      # so that we do not hard code it again here).
      expect(assigns(:message)).to_not be_nil

      # XXX Test a delivery entry was made
    end

  end

end