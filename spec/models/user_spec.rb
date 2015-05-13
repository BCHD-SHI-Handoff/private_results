require "rails_helper"

describe User do

  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  let(:user) { build(:user) }

  describe "ActiveModel validations" do
    it { expect(user).to validate_presence_of(:email) }
    it { expect(user).to validate_presence_of(:role) }
  end

end
