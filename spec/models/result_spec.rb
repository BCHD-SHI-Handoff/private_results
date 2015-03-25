require "rails_helper"

describe Result do

  it "has a valid factory" do
    expect(build(:result)).to be_valid
  end

  let(:result) { build(:result) }

  describe "ActiveModel validations" do
    it { expect(result).to validate_presence_of(:visit) }
    it { expect(result).to validate_presence_of(:test) }
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
end
