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

  describe "hours_for_language" do
    it { expect(clinic.hours_for_language("english")).to eq clinic.hours_in_english }
    it { expect(clinic.hours_for_language("spanish")).to eq clinic.hours_in_spanish }
  end
end
