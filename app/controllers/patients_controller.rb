require 'csv'

class PatientsController < ApplicationController
  def index
    respond_to do |format|
      format.html {
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
      }

      format.csv {
        start_date = Time.at(params['start'].to_i / 1000).beginning_of_day
        end_date = Time.at(params['end'].to_i / 1000).end_of_day
        csv_data = CSV.generate({}) do |csv|
          # Set our headers for the CSV file (first row).
          csv << [
            "patient_no",
            "username",
            "password",
            'visit_date',
            'cosite',
            'infection',
            'result',
            'result_last_changed', 
            'delivery_status'
          ]

          # Grab all visits within our date range and include their clinic and results data.
          visits = Visit
            .includes(:clinic, results: [:test, :status, :deliveries])
            .where(visited_on: start_date..end_date)
            .all

          # For each result in each visit, add a row to our CSV.
          visits.each do |visit|
            visit.results.each do |result|
              csv << [
                visit.patient_number,
                visit.username,
                visit.password,
                visit.visited_on,
                visit.clinic.code,
                result.test.name,
                result.status.nil? ? nil : result.status.status,
                result.recorded_on,
                result.deliveries.length > 0 ? "delivered" : "not delivered"
              ]
            end
          end
        end
        # Send the data so that is downloaded.
        send_data csv_data
      }
    end
  end
end