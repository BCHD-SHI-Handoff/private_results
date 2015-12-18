class AddAuditTable < ActiveRecord::Migration
  def change
    create_table :audit_logs do |t|
      t.timestamps
      t.integer :user_id, null: false
      t.string :user_email, null: false
      t.string :viewed_patient_number
      t.datetime :viewed_csv_start_date
      t.datetime :viewed_csv_end_date
    end
  end
end
