require "rails_helper"

# See https://robots.thoughtbot.com/test-rake-tasks-like-a-boss
# for details on how this was setup.
describe "import:csv" do
  include_context "rake"

  it "should import patients file" do
    # Run our import and provide the csv file to import.
    ENV['file'] = "sample_import.csv"
    subject.invoke

    # All data should be derived from the imported CSV file.
    expect(Visit.all.length).to eq 100
    expect(Result.all.length).to eq 266

    p100 = Visit.where(username: "10033", password: "10034").first
    expect(p100.patient_number).to eq "100"
    expect(p100.clinic.code).to eq "E"
    expect(p100.results.length).to eq 18
    expect(p100.get_latest_results.length).to eq 6

    p102 = Visit.where(username: "10233", password: "10234").first
    expect(p102.patient_number).to eq "102"
    expect(p102.clinic.code).to eq "D"
    expect(p102.results.length).to eq 4
    expect(p102.results[0].test.name).to eq "Chlamydia"
    expect(p102.results[1].test.name).to eq "Gonorrhea"
    expect(p102.results[2].test.name).to eq "Hepatitis B"
    expect(p102.results[3].test.name).to eq "Hepatitis C"
  end
end