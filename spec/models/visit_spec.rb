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
    describe "get_results_message" do
      it "should return pending message if recent visit and at least one result is pending" do
        # Create a visit that is less than 5 days old (recent) and has at least one result pending.
        visit = create(:visit, visited_on: 3.days.ago)
        visit.results << create(:result, status: Status.find_by_status("Pending"), test: Test.find_by_name("Chlamydia"))
        visit.results << create(:result, status: Status.find_by_status("Negative"), test: Test.find_by_name("Gonorrhea"))
        visited_on_date = visit.visited_on.strftime("%A, %B #{visit.visited_on.day.ordinalize}")
        results_ready_on = visit.visited_on + 7.days
        results_ready_date = results_ready_on.strftime("%A, %B #{results_ready_on.day.ordinalize}")
        actual_message = "You visited #{visit.clinic.name} on #{visited_on_date} and were tested for Chlamydia and Gonorrhea."
        actual_message += "\n\n"
        actual_message += "Your test results are still pending. Please call back on #{results_ready_date} to get your test results."
        actual_message += "\n\n\n"
        actual_message += "Thank you for calling!"
        expect(visit.get_results_message("english")).to eq actual_message
      end

      it "should return results message" do
        visit = create(:visit)
        visit.results << create(:result, status: Status.find_by_status("Immune"), test: Test.find_by_name("Hepatitis B"))
        visit.results << create(:result, status: Status.find_by_status("Negative"), test: Test.find_by_name("Gonorrhea"))
        visit.results << create(:result, status: Status.find_by_status("Positive"), test: Test.find_by_name("Hepatitis C"))
        visited_on_date = visit.visited_on.strftime("%A, %B #{visit.visited_on.day.ordinalize}")
        actual_message = "You visited #{visit.clinic.name} on #{visited_on_date} and were tested for Hepatitis B, Gonorrhea, and Hepatitis C."
        actual_message += "\n\n"
        actual_message += "Your hepatitis B test results show you are immune to hepatitis B. You do not need to return to the clinic."
        actual_message += "\n\n"
        actual_message += "Your gonorrhea test was negative, which means that you probably do not have gonorrhea."
        actual_message += "\n\n"
        actual_message += "Your hepatitis C test was positive, which means that you have been exposed to hepatitis C. "
        actual_message += "You need further evaluation. Please return to the clinic. Clinic hours are #{visit.clinic.hours_for_language("english")}."
        actual_message += "\n\n"
        actual_message += "Thank you for calling!"
        expect(visit.get_results_message("english")).to eq actual_message
      end

    end
  end
end
