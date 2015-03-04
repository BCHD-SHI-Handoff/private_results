class PatientsController < ApplicationController
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
end