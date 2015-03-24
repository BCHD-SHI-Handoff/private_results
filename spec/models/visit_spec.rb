require "rails_helper"

describe Visit do

  it "has a valid factory" do
    expect(build(:visit)).to be_valid
    expect(build(:visit_with_results)).to be_valid
  end

  let(:visit) { build(:visit) }

  describe "ActiveModel validations" do
    it { expect(visit).to validate_presence_of(:patient_number) }
    it { expect(visit).to validate_presence_of(:clinic) }
    it { expect(visit).to validate_presence_of(:username) }
    it { expect(visit).to validate_presence_of(:password) }
    it { expect(visit).to validate_presence_of(:visited_on) }

    it { expect(visit).to validate_uniqueness_of(:username).scoped_to(:password) }
  end

  describe "ActiveRecord associations" do
    it { expect(visit).to belong_to(:clinic) }
    it { expect(visit).to have_many(:results) }
  end

  describe "public instance methods" do

    describe "test_names" do
      it "should return array of test names" do
        visit = create(:visit_with_results)
        test_names = []
        visit.results.each do |result|
          test_names << result.test.name
        end
        expect(visit.test_names).to match_array(test_names)
      end
    end

    describe "test_messages" do
      it "should return all of the results compiled into a message" do
        visit = create(:visit)

        chlamydia_test = Test.find_by_name("Chlamydia")
        gonorrhea_test = Test.find_by_name("Gonorrhea")
        negative_status = Status.find_by_status("Negative")

        visit.results << create(:result, test_id: gonorrhea_test.id , status_id: negative_status.id)
        visit.results << create(:result, test_id: chlamydia_test.id , status_id: nil)
        actual_message = "Your gonorrhea test was negative, which means that you probably do not have gonorrhea."
        actual_message += "\n\n"
        actual_message += "I am not able to read you chlamydia test result. You will have to come back to"
        actual_message += " the clinic in order to get your chlamydia test results. Clinic hours are monday to friday."
        expect(visit.test_messages({"clinic_hours" => "monday to friday"})).to eq actual_message
      end
    end

    describe "visited_on_date" do
      it "should properly format date in english" do
        visit = create(:visit, visited_on: Time.at(1427162681))
        expect(visit.visited_on_date).to eq "Tuesday, March 24th"
      end

      it "should properly format date in spanish" do
        I18n.locale = :es # Set locale to spanish
        visit = create(:visit, visited_on: Time.at(1427162681))
        expect(visit.visited_on_date).to eq "martes, marzo 24"
        I18n.locale = :en # Set it back for other tests
      end
    end

    describe "results_ready_on" do
      it "should be 5 days from visit" do
        visit = create(:visit, visited_on: Time.at(1427162681))
        expect(visit.results_ready_on).to eq "Sunday, March 29th"
      end
    end

    describe "is_recent?" do
      it "should return true when visited_on date is less than 5 days ago" do
        visit = create(:visit, visited_on: 3.days.ago)
        expect(visit.is_recent?).to eq true
      end

      it "should return false when visited_on date is greater than 5 days ago" do
        visit = create(:visit, visited_on: 6.days.ago)
        expect(visit.is_recent?).to eq false
      end
    end

    describe "has_pending_results?" do
      it "should return true when there's at least one pending result" do
        pending_status = Status.find_by_status("Pending")
        visit = create(:visit)
        visit.results << create(:result)
        visit.results << create(:result, status_id: pending_status.id)
        expect(visit.has_pending_results?).to eq true
      end

      it "should return false when there's zero pending results" do
        negative_status = Status.find_by_status("Negative")
        visit = create(:visit)
        visit.results << create(:result, status_id: nil)
        visit.results << create(:result, status_id: negative_status.id)
        expect(visit.has_pending_results?).to eq false
      end
    end

    describe "require_clinic_visit?" do
      it { expect(visit.require_clinic_visit?).to eq false }
    end
  end
end
