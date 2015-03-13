require "rails_helper"

describe Clinic do

  let(:clinic) { Clinic.all.first }

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
