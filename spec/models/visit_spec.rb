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
      it "should return come back message if at least one result has a come back status" do
        # Create a visit that is less than 7 days old (recent) and has at least one result pending.
        visit = create(:visit)
        visit.results << create(:result, status: Status.find_by_status("Come back to clinic"), test: Test.find_by_name("Chlamydia"))
        visit.results << create(:result, status: Status.find_by_status("Negative"), test: Test.find_by_name("Gonorrhea"))
        visited_on_date = visit.visited_on.strftime("%A, %B #{visit.visited_on.day.ordinalize}")
        clinic_hours = visit.clinic.hours_for_language("english")
        actual_message = "You visited #{visit.clinic.name} on #{visited_on_date} and were tested for Chlamydia and Gonorrhea."
        actual_message += "\n\n"
        actual_message += "One or more of your test results requires medical attention. "
        actual_message += "Please come back to the clinic as soon as possible. The clinic hours are #{ clinic_hours }."
        actual_message += "\n\n\n"
        actual_message += "Thank you for calling!"
        expect(visit.get_results_message("english", "phone")).to eq actual_message

        # Check result delivery is marked as come_back.
        expect(visit.results.first.come_back?).to eq true
        expect(visit.results.last.come_back?).to eq true
      end

      it "should return pending message if recent visit and at least one result is pending" do
        # Create a visit that is less than 7 days old (recent) and has at least one result pending.
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
        expect(visit.get_results_message("english", "phone")).to eq actual_message

        # Check result delivery is marked as not_delivered.
        expect(visit.results.first.not_delivered?).to eq true
        expect(visit.results.last.not_delivered?).to eq true
      end

      it "should return results message" do
        visit = create(:visit, visited_on: 8.days.ago)
        visit.results << create(:result, status: Status.find_by_status("Immune"), test: Test.find_by_name("Hepatitis B"))
        visit.results << create(:result, status: Status.find_by_status("Negative"), test: Test.find_by_name("Gonorrhea"))
        visit.results << create(:result, status: Status.find_by_status("Pending"), test: Test.find_by_name("Syphilis"))
        visit.results << create(:result, status: Status.find_by_status("Hep C Positive"), test: Test.find_by_name("Hepatitis C"))
        visited_on_date = visit.visited_on.strftime("%A, %B #{visit.visited_on.day.ordinalize}")
        clinic_hours = visit.clinic.hours_for_language("english")
        actual_message = "You visited #{visit.clinic.name} on #{visited_on_date} and were tested for Hepatitis B, Gonorrhea, Syphilis, and Hepatitis C."
        actual_message += "\n\n"
        actual_message += "Your hepatitis B test results show you are immune to hepatitis B. You do not need to return to the clinic."
        actual_message += "\n\n"
        actual_message += "Your gonorrhea test was negative, which means that you probably do not have gonorrhea."
        actual_message += "\n\n"
        actual_message += "Your syphilis test result is still pending. Call back tomorrow to see if your syphilis result is ready."
        actual_message += "\n\n"
        actual_message += "Your hepatitis C test was positive, which means that you have been exposed to hepatitis C. "
        actual_message += "You need further evaluation. Please return to the clinic. Clinic hours are #{clinic_hours}."
        actual_message += "\n\n\n"
        actual_message += "Thank you for calling!"
        expect(visit.get_results_message("english", "phone")).to eq actual_message

        # Check result delivery status.
        expect(visit.results[0].delivered?).to eq true
        expect(visit.results[1].delivered?).to eq true
        expect(visit.results[2].delivered?).to eq false
        expect(visit.results[2].not_delivered?).to eq true
        expect(visit.results[3].delivered?).to eq true
      end

    end
  end
end
