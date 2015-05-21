require "rails_helper"

describe Clinic do

  let(:clinic) { build(:clinic) }

  describe "ActiveModel validations" do
    it { expect(clinic).to validate_presence_of(:code) }
    it { expect(clinic).to validate_presence_of(:name) }
    it { expect(clinic).to validate_presence_of(:hours_in_english) }
    it { expect(clinic).to validate_presence_of(:hours_in_spanish) }
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

  it "uses soft delete" do
    clinic.save!
    expect(clinic.id).to_not be_nil
    expect(clinic.deleted_at).to be_nil

    # Delete the clinic and check that deleted_at is now not nil.
    clinic.destroy
    expect(clinic.deleted_at).to_not be_nil

    # Looking for this clinic should return nil.
    expect(Clinic.find_by_id(clinic.id)).to be_nil

    # Clinic still exists when searching with_deleted.
    expect(Clinic.with_deleted.find(clinic.id)).to_not be_nil

    # Restoring clinic un-deletes it.
    clinic.restore!
    expect(Clinic.find(clinic.id)).to_not be_nil
    expect(clinic.deleted_at).to be_nil
  end
end
