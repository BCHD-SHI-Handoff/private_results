require 'csv'

# Usage: "rake import:csv file=path/to/patients_data.csv"
namespace :import do
  desc "Imports a csv file of patient visits and results data."
  task csv: :environment do
    unknown_clinic = Clinic.find_by_code('U')

    chlamydia_test = Test.find_by_name("Chlamydia")
    gonorrhea_test = Test.find_by_name("Gonorrhea")
    syphilis_test = Test.find_by_name("Syphilis")
    hiv_test = Test.find_by_name("HIV")
    hepb_test = Test.find_by_name("Hepatitis B")
    hepc_test = Test.find_by_name("Hepatitis C")

    # Rows are expected to be in the following format:
    # {
    #   "patient_no": "100359",
    #   "username": "387905",
    #   "password": "754367",
    #   "visit_date": "15-Nov-09",
    #   "cosite": "E",
    #   "cttested": "0", "ctresult": null,
    #   "gctested": "1", "gcresult": "Negative",
    #   "hivtested": "1", "hivresult": "Negative",
    #   "syphtested": "1", "syphresult": "Negative",
    #   "hepbtested": "0", "hepbresult": null,
    #   "hepctested": "0", "hepcresult": null
    # }

    # Try to read and parse the file.
    begin
      csv = CSV.parse(File.read(ENV['file']), :headers => true)
    rescue
      puts "Unable to read and parse csv file: '#{ENV['file']}'"
      exit
    end

    csv.each do |row|
      # Find existing visit by username and password.
      visit = Visit.where(username: row['username'], password: row['password']).first

      # Create new visit if one doesn't already exist.
      if visit.nil?
        visit = Visit.create({
          patient_number: row["patient_no"],
          clinic_id: Clinic.where(code: row['cosite']).pluck('id').first || unknown_clinic.id,
          visited_on: Time.parse(row['visit_date']),
          username: row['username'],
          password: row['password']
        })
      end

      # Record all of the results.
      record_result(row, visit, 'ct', chlamydia_test)
      record_result(row, visit, 'gc', gonorrhea_test)
      record_result(row, visit, 'syph', syphilis_test)
      record_result(row, visit, 'hiv', hiv_test)
      record_result(row, visit, 'hepb', hepb_test)
      record_result(row, visit, 'hepc', hepc_test)
    end
  end

  def record_result(row, visit, test_abbr, test)
    if row["#{test_abbr}tested"] == '1'
      result = Result.create({
        visit_id: visit.id,
        test_id: test.id,
        status_id: Status.where(status: row["#{test_abbr}result"]).pluck(:id).first,
        recorded_on: Time.now
      })
    end
  end
end
