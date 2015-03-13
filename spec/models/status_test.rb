require "rails_helper"

describe Status do

  it "has a valid factory" do
    expect(build(:status)).to be_valid
  end

  let(:status) { build(:status) }

  describe "ActiveModel validations" do
    it { expect(status).to validate_presence_of(:status) }
    it { expect(status).to validate_uniqueness_of(:status) }
  end

  describe "ActiveRecord associations" do
    it { expect(status).to have_many(:results) }
  end
end
