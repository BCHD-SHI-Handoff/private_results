class PatientsController < ApplicationController
  before_filter :verify_is_admin, only: [:export]

  def index
    @patient_number = nil
    @visits = nil
    if params[:patient_number].present?
      @patient_number = params[:patient_number]
      @visits =
        Visit
          .includes(:clinic, results: [:test, :status, :deliveries])
          .where(patient_number: params[:patient_number])
          .order(visited_on: :desc)
          .all
    end

    render "/patients"
  end

  def export
    # Round our start and end dates to the beginning and end of the days, respectively.
    # This ensures that we get every visit that happened on those days.
    start_date = Time.at(params['start'].to_i / 1000).beginning_of_day
    end_date = Time.at(params['end'].to_i / 1000).end_of_day
    send_data Visit.get_csv(start_date, end_date)
  end
end