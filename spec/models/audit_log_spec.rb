require "rails_helper"

describe AuditLog do

  it "has a valid factory" do
    expect(build(:audit_log)).to be_valid
  end

  it "should be read only" do
      auditLog = create(:audit_log)
      auditLog.user_id = 12345
      expect{auditLog.save}.to raise_error ActiveRecord::ReadOnlyRecord
  end

  describe "viewed_patient_number" do
    it "should create an audit log entry" do

      user = create(:user)
      foo = AuditLog.viewed_patient_number(user, "12345")
      expect(AuditLog.all.length).to eq 1
      expect(AuditLog.first.user_id).to eq user.id
      expect(AuditLog.first.user_email).to eq user.email
      expect(AuditLog.first.viewed_patient_number).to eq "12345"
    end
  end

  describe "viewed_csv" do
    it "should create an audit log entry" do

      user = create(:user)
      start_date = 30.days.ago
      end_date = 10.days.ago
      foo = AuditLog.viewed_csv(user, start_date, end_date)
      expect(AuditLog.all.length).to eq 1
      expect(AuditLog.first.user_id).to eq user.id
      expect(AuditLog.first.user_email).to eq user.email
      expect(AuditLog.first.viewed_csv_start_date).to eq start_date
      expect(AuditLog.first.viewed_csv_end_date).to eq end_date
    end
  end

  describe "get_csv" do
    it "should return csv data for audit logs between start and end date" do
      logs = create_list(:audit_log, 10)

      data = AuditLog.get_csv(200.days.ago, Time.now) # Factory only goes back 180 days
      data = data.split("\n").map{|row| row.split(",")}

      # 1 header, 10 logs
      expect(data.length).to eq 11

      # Check header row
      expect(data[0]).to eq ['created_at', 'user_id', 'user_email', 'viewed_patient_number',
                             'viewed_csv_start_date', 'viewed_csv_end_date']

      # Check first record.
      log1 = AuditLog.first
      expect(data[1][0]).to eq log1.created_at.to_s
      expect(data[1][1]).to eq log1.user_id.to_s
      expect(data[1][2]).to eq log1.user_email
      expect(data[1][3]).to eq log1.viewed_patient_number.to_s
      expect(data[1][4]).to eq log1.viewed_csv_start_date ? log1.viewed_csv_start_date.to_s : nil
      expect(data[1][5]).to eq log1.viewed_csv_end_date ? log1.viewed_csv_end_date.to_s : nil
    end
  end
end
