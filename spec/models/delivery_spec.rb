require "rails_helper"

describe Delivery do

  it "has a valid factory" do
    expect(build(:delivery)).to be_valid
  end

  let(:delivery) { build(:delivery) }

  describe "ActiveModel validations" do
    it { expect(delivery).to validate_presence_of(:delivered_at) }
    it { expect(delivery).to validate_presence_of(:delivery_method) }
    it { expect(delivery).to validate_presence_of(:message) }

    it { expect(delivery).to validate_inclusion_of(:delivery_method).in_array(["phone", "online"]) }
  end

  describe "ActiveRecord associations" do
    it { expect(delivery).to have_and_belong_to_many(:results) }
  end
end
