require "rails_helper"

describe Test do

  let(:test) { Test.all.first }

  describe "ActiveModel validations" do
    it { expect(test).to validate_presence_of(:name) }
    it { expect(test).to validate_uniqueness_of(:name) }
  end

  describe "ActiveRecord associations" do
    it { expect(test).to have_many(:scripts) }
    it { expect(test).to have_many(:results) }
  end
end