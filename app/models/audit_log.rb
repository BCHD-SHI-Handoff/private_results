require 'csv'

class AuditLog < ActiveRecord::Base
  # Prevent editing existing records.
  def readonly?
    !new_record?
  end

  def self.viewed_patient_number(current_user, patient_number)
    self.create(
      user_id: current_user.id,
      user_email: current_user.email,
      viewed_patient_number: patient_number
    )
  end

  def self.viewed_csv(current_user, start_date, end_date)
    self.create(
      user_id: current_user.id,
      user_email: current_user.email,
      viewed_csv_start_date: start_date,
      viewed_csv_end_date: end_date
    )
  end

  def self.get_csv(start_date, end_date)
    # Grab all logs within our date range.
    logs = AuditLog.where(created_at: start_date..end_date)

    rows = []
    logs.each do |log|
      rows.push(
        {
          'created_at' => log.created_at,
          'user_id' => log.user_id,
          'user_email' => log.user_email,
          'viewed_patient_number' => log.viewed_patient_number,
          'viewed_csv_start_date' => log.viewed_csv_start_date,
          'viewed_csv_end_date' => log.viewed_csv_end_date,
        }
      )
    end

    csv_data = CSV.generate({}) do |csv|
      if !rows.blank?
        csv << rows.first.keys
        rows.each do |row|
          csv << row.values
        end
      end
    end

    csv_data
  end
end
