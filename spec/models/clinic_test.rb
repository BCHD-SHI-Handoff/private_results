require "rails_helper"

describe Clinic do

  it "has a valid factory" do
    expect(build(:clinic)).to be_valid
  end

  let(:clinic) { build(:clinic) }

  describe "ActiveModel validations" do
    it { expect(clinic).to validate_presence_of(:code) }
    it { expect(clinic).to validate_presence_of(:name) }
    it { expect(clinic).to validate_uniqueness_of(:code) }
    it { expect(clinic).to validate_uniqueness_of(:name) }
  end

  describe "ActiveRecord associations" do
    it { expect(clinic).to have_many(:visits) }
  end
end
