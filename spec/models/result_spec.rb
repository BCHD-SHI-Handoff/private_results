require "rails_helper"

describe Result do
  it "has a valid factory" do
    expect(build(:result)).to be_valid
  end

  let(:result) { build(:result) }

  describe "ActiveModel validations" do
    it { expect(result).to validate_presence_of(:visit) }
    it { expect(result).to validate_presence_of(:test) }
    it { expect(result).to validate_presence_of(:delivery_status) }
  end

  describe "ActiveRecord associations" do
    it { expect(result).to belong_to(:visit) }
    it { expect(result).to belong_to(:test) }
    it { expect(result).to belong_to(:status) }
    it { expect(result).to have_and_belong_to_many(:deliveries) }
  end

  describe "message" do
    it "should get the correct message for the given test and status" do
      # Some scripts have a clinic_hours placeholder, so we need to make sure
      # we account for that!
      expected_message = Script.select(:message)
        .find_by(test_id: result.test_id, status_id: result.status_id)
        .message.sub("{{ clinic_hours }}", "monday to friday")
      actual_message = result.message({"clinic_hours" => "monday to friday"})
      expect(actual_message).to eq expected_message
    end
  end

  describe "update_delivery_status" do
    it "should set delivery_status passed in" do
      result1 = build(:result)
      result2 = build(:result)
      result3 = build(:result)
      result1.update_delivery_status(Result.delivery_statuses[:not_delivered])
      expect(result1.not_delivered?).to eq true
      expect(result1.come_back?).to eq false
      expect(result1.delivered?).to eq false

      result2.update_delivery_status(Result.delivery_statuses[:come_back])
      expect(result2.not_delivered?).to eq false
      expect(result2.come_back?).to eq true
      expect(result2.delivered?).to eq false

      result3.update_delivery_status(Result.delivery_statuses[:delivered])
      expect(result3.not_delivered?).to eq false
      expect(result3.come_back?).to eq false
      expect(result3.delivered?).to eq true
    end

    it "should set delivery_status based on status" do
      result.status = nil
      result.update_delivery_status(nil)
      expect(result.not_delivered?).to eq true

      result.status = Status.find_by_status("Pending")
      result.update_delivery_status(nil)
      expect(result.not_delivered?).to eq true

      result.status = Status.find_by_status("Come back to clinic")
      result.update_delivery_status(nil)
      expect(result.come_back?).to eq true

      result.status = Status.find_by_status("Negative")
      result.update_delivery_status(nil)
      expect(result.delivered?).to eq true
    end

    it "should not change a come_back result to not_delivered" do
      result.come_back!
      result.update_delivery_status(Result.delivery_statuses[:not_delivered])
      expect(result.come_back?).to eq true
    end

    it "should change a come_back result to delivered" do
      result.come_back!
      result.update_delivery_status(Result.delivery_statuses[:delivered])
      expect(result.delivered?).to eq true
    end

    it "should not change a delivered result" do
      result.delivered!
      result.update_delivery_status(Result.delivery_statuses[:come_back])
      expect(result.delivered?).to eq true

      result.update_delivery_status(Result.delivery_statuses[:not_delivered])
      expect(result.delivered?).to eq true
    end
  end
end
