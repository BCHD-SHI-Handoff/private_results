if Rails.env == "development" || Rails.env == "production"
  user = User.create(
    email: DEFAULT_USER_EMAIL, # Found in config/initializers/constants.rb
    password: DEFAULT_USER_PASSWORD,
    password_confirmation: DEFAULT_USER_PASSWORD,
    role: :admin,
    active: true
  )
  user.confirm!
  SeedData::populate()
end

#######################
#     DUMMY DATA      #
#######################
if Rails.env == "development"
  # These should come from SeedData
  chlamydia_test = Test.find_by_name("Chlamydia")
  gonorrhea_test = Test.find_by_name("Gonorrhea")
  syphilis_test = Test.find_by_name("Syphilis")
  hiv_test = Test.find_by_name("HIV")
  hepb_test = Test.find_by_name("Hepatitis B")
  hepc_test = Test.find_by_name("Hepatitis C")
  status_negative = Status.find_by_status("Negative")
  status_positive_and_treated = Status.find_by_status("Positive and treated")
  status_immune = Status.find_by_status("Immune")
  status_need_vaccination = Status.find_by_status("Need vaccination")
  status_hepb_infected = Status.find_by_status("Hep B infected")
  status_pending = Status.find_by_status("Pending")
  status_positive = Status.find_by_status("Positive")
  status_come_back = Status.find_by_status("Come back to clinic")

  # Setup an array of all of our tests and there possible statuses.
  tests = [
    {test_id: chlamydia_test.id, statuses: [status_negative, status_positive_and_treated, status_pending, status_come_back, nil]},
    {test_id: gonorrhea_test.id, statuses: [status_negative, status_positive_and_treated, status_pending, status_come_back, nil]},
    {test_id: syphilis_test.id, statuses: [status_negative, status_positive_and_treated, status_pending, status_come_back, nil]},
    {test_id: hiv_test.id, statuses: [status_negative, status_pending, status_come_back, nil]},
    {test_id: hepb_test.id, statuses: [status_immune, status_need_vaccination, status_hepb_infected, status_pending, status_come_back, nil]},
    {test_id: hepc_test.id, statuses: [status_negative, status_positive, status_pending, status_come_back, nil]}
  ]

  # Create 100 visits for up to 10 different patients.
  100.times do |k|
    visited_on = rand(14.months.ago..Time.now)
    visit = Visit.create({
      patient_number: rand(10),
      clinic_id: (Clinic.all.sample).id,
      visited_on: visited_on,
      username: rand(1000000000..99999999999).to_s,
      password: rand(1000000000..99999999999).to_s
    })

    delivery = nil
    if [true, false].sample # Flip a coin if the results were delivered.
      delivery_method = ['phone', 'online'].sample
      delivery = Delivery.create({
         # Randomly pick a date up to 7 days after visit.
        delivered_at: rand(visited_on..(visited_on + 7.days)),
        delivery_method: delivery_method,
        phone_number_used: delivery_method == 'phone' ? "555-555-5555": nil,
        message: "This is a fake message. In production this would be the complete message the patient received."
      })
    end

    tests_for_visit = tests.sample(rand(3) + 1)
    tests_for_visit.each do |test|
      status = test[:statuses].sample
      result = Result.new({
        visit_id: visit.id,
        test_id: test[:test_id],
        status_id: status.nil? ? nil : status.id,
        recorded_on: visited_on + 1.days
      })
      if !delivery.nil?
        result.deliveries << delivery
      end
      result.save
    end
  end
end
