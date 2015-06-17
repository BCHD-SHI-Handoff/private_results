require "rails_helper"

describe Script do

  let(:script) { Script.all.first }

  describe "ActiveModel validations" do
    it { expect(script).to validate_presence_of(:message) }
    it { expect(script).to validate_presence_of(:language) }

    it "validates presense and uniqueness of name when test_id & status_id are nil" do
      named_script = Script.create({name: "fake script name", language: "english", message: "hello world"})
      expect(named_script).to validate_presence_of(:name)
      expect(named_script).to validate_uniqueness_of(:name)
    end

    it "validates presense of test_id when name is nil" do
      test_script = Script.create({test_id: 33424, status_id: 3432434, language: "english", message: "hello world"})
      expect(test_script).to validate_presence_of(:test_id)
      expect(test_script).to validate_presence_of(:status_id)
    end
  end

  describe "ActiveRecord associations" do
    it { expect(script).to belong_to(:test) }
    it { expect(script).to belong_to(:status) }
  end

  describe "public instance methods" do
    describe "get_message" do
      it "should return message" do
        expect(Script.get_message("language_not_selected")).to eq "Sorry, I didn't get that."
      end
    end
  end
end
