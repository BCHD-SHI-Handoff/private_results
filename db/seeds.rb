if Rails.env == "test"
  # Doh! Having a test model clashes with a Test constant rails uses.
  Object.send(:remove_const, :Test)
end

user = User.create(email: "admin@example.com", password: "adminadmin", password_confirmation: "adminadmin", role: 0, active: true)
user.confirm!

#######################
#       CLINICS       #
#######################
clinics = Clinic.create([
  {code: "C", name: "Central Clinic", hours_in_english: "Monday to Friday, 9am to 5pm", hours_in_spanish: "Lunes a Viernes, 9am a 5pm"},
  {code: "D", name: "Druid Clinic", hours_in_english: "Monday to Friday, 9am to 5pm", hours_in_spanish: "Lunes a Viernes, 9am a 5pm"},
  {code: "E", name: "Eastern Clinic", hours_in_english: "Monday to Friday, 9am to 5pm", hours_in_spanish: "Lunes a Viernes, 9am a 5pm"},
  {code: "TB", name: "TB Clinic", hours_in_english: "Monday to Friday, 9am to 5pm", hours_in_spanish: "Lunes a Viernes, 9am a 5pm"},
  {code: "U", name: "Unknown", hours_in_english: "Monday to Friday, 9am to 5pm", hours_in_spanish: "Lunes a Viernes, 9am a 5pm"},
])

#######################
#        TESTS        #
#######################
chlamydia_test = Test.create(name: "Chlamydia")
gonorrhea_test = Test.create(name: "Gonorrhea")
syphilis_test = Test.create(name: "Syphilis")
hiv_test = Test.create(name: "HIV")
hepb_test = Test.create(name: "Hepatitis B")
hepc_test = Test.create(name: "Hepatitis C")

#######################
#      STATUSES       #
#######################
status_negative = Status.create(status: "Negative")
status_positive = Status.create(status: "Positive")
status_positive_and_treated = Status.create(status: "Positive and treated")
status_pending = Status.create(status: "Pending")
status_immune = Status.create(status: "Immune")
status_need_vaccination = Status.create(status: "Need vaccination")
status_hepb_infected = Status.create(status: "Hep B infected")

#######################
#       SCRIPTS       #
#######################
Script.create({
  name: 'error',
  language: 'english',
  message: "Sorry, an unknown error occurred, please contact the clinic."
})

Script.create({
  name: 'language_not_selected',
  language: 'english',
  message: "Sorry, I didn't get that."
})

Script.create({
  name: 'welcome',
  language: 'english',
  message: "Hello, and thank you for calling."
})

Script.create({
  name: 'username_prompt',
  language: 'english',
  message: "Please enter the username on your card, followed by the pound sign."
})

Script.create({
  name: 'username_prompt_repeat',
  language: 'english',
  message: "We did not receive your username."
})

Script.create({
  name: 'username_prompt_invalid',
  language: 'english',
  message: "We couldn’t find the username '{{ username }}' in our system. If you think this is an error, please contact the clinic."
})

Script.create({
  name: 'password_prompt',
  language: 'english',
  message: "Please enter the password on your card, followed by the pound sign."
})

Script.create({
  name: 'password_prompt_repeat',
  language: 'english',
  message: "We did not receive your password."
})

Script.create({
  name: 'password_prompt_invalid',
  language: 'english',
  message: "The password '{{ password }}' does not match the username '{{ username }}' that you provided. If you think this is an error, please contact the clinic."
})

Script.create({
  name: 'master',
  language: 'english',
  message: "You visited {{ clinic_name }} on {{ visit_date }} and were tested for {{ test_names }}.

{% if recent_visit_with_pending_results %}Your test results are still pending. Please call back on {{ results_ready_on }} to get your test results.
{% elsif any_results_require_clinic_visit %}One or more of your test results requires medical attention. Please come back to the clinic as soon as possible. The clinic hours are {{ clinic_hours }}.
{% else %}{{ test_messages }}{% endif %}

Thank you for calling!"
})

Script.create({
  name: 'to_repeat_message',
  language: 'english',
  message: "To replay this message, press any key."
})

#######################
#      CHLAMYDIA      #
#######################
Script.create({
  language: 'english',
  test_id: chlamydia_test.id,
  status_id: status_negative.id,
  message: "Your chlamydia test was negative, which means that you probably do not have chlamydia."
})

Script.create({
  language: 'english',
  test_id: chlamydia_test.id,
  status_id: status_positive_and_treated.id,
  message: "Your chlamydia test was positive, which means that you had chlamydia at the time you were tested. You were treated for chlamydia in the clinic already, so you were cured of chlamydia at that time and do not need to come back to the clinic. You do need to tell your partners so that they can get treated for chlamydia."
})

Script.create({
  language: 'english',
  test_id: chlamydia_test.id,
  status_id: status_pending.id,
  message: "Your chlamydia test result is still pending. Call back tomorrow to see if your chlamydia result is ready."
})

Script.create({
  language: 'english',
  test_id: chlamydia_test.id,
  message: "I am not able to read your chlamydia test result. You will have to come back to the clinic in order to get your chlamydia test results. Clinic hours are {{ clinic_hours }}."
})

#######################
#      GONORRHEA      #
#######################
Script.create({
  language: 'english',
  test_id: gonorrhea_test.id,
  status_id: status_negative.id,
  message: "Your gonorrhea test was negative, which means that you probably do not have gonorrhea."
})

Script.create({
  language: 'english',
  test_id: gonorrhea_test.id,
  status_id: status_positive_and_treated.id,
  message: "Your gonorrhea test was positive, which means that you had gonorrhea at the time you were tested. You were treated for gonorrhea in the clinic already, so you were cured of gonorrhea at that time and do not need to come back to the clinic. You do need to tell your partners so that they can get treated for gonorrhea."
})

Script.create({
  language: 'english',
  test_id: gonorrhea_test.id,
  status_id: status_pending.id,
  message: "Your gonorrhea test result is still pending. Call back tomorrow to see if your gonorrhea result is ready."
})

Script.create({
  language: 'english',
  test_id: gonorrhea_test.id,
  message: "I am not able to read your gonorrhea test result. You will have to come back to the clinic in order to get your gonorrhea test results. Clinic hours are {{ clinic_hours }}."
})

#######################
#      SYPHILIS       #
#######################
Script.create({
  language: 'english',
  test_id: syphilis_test.id,
  status_id: status_negative.id,
  message: "Your syphilis test was negative, which means that you probably do not have syphilis."
})

Script.create({
  language: 'english',
  test_id: syphilis_test.id,
  status_id: status_positive_and_treated.id,
  message: "Your syphilis test was positive, which means that you had syphilis at the time you were tested. You were treated for syphilis in the clinic already, so you were cured of syphilis at that time and do not need to come back to the clinic. You do need to tell your partners so that they can get treated for syphilis."
})

Script.create({
  language: 'english',
  test_id: syphilis_test.id,
  status_id: status_pending.id,
  message: "Your syphilis test result is still pending. Call back tomorrow to see if your syphilis result is ready."
})

Script.create({
  language: 'english',
  test_id: syphilis_test.id,
  message: "I am not able to read your syphilis test result. You will have to come back to the clinic in order to get your syphilis test results. Clinic hours are {{ clinic_hours }}."
})

#######################
#         HIV         #
#######################
Script.create({
  language: 'english',
  test_id: hiv_test.id,
  status_id: status_negative.id,
  message: "Your HIV test was negative, which means that you probably do not have HIV."
})

Script.create({
  language: 'english',
  test_id: hiv_test.id,
  status_id: status_pending.id,
  message: "Your HIV test result is still pending. Call back tomorrow to see if your HIV result is ready."
})

Script.create({
  language: 'english',
  test_id: hiv_test.id,
  message: "I am not able to read your HIV test result. You will have to come back to the clinic in order to get your HIV test results. Clinic hours are {{ clinic_hours }}."
})

#######################
#     HEPATITIS B     #
#######################
Script.create({
  language: 'english',
  test_id: hepb_test.id,
  status_id: status_immune.id,
  message: "Your hepatitis B test results show you are immune to hepatitis B. You do not need to return to the clinic."
})

Script.create({
  language: 'english',
  test_id: hepb_test.id,
  status_id: status_need_vaccination.id,
  message: "Your hepatitis B test results show that you need to get vaccinated for hepatitis B. Please return to the clinic to get vaccinated. Clinic hours are {{ clinic_hours }}."
})

Script.create({
  language: 'english',
  test_id: hepb_test.id,
  status_id: status_hepb_infected.id,
  message: "Your hepatitis B test results show that you have evidence of hepatitis B and need to come back to the clinic. Clinic hours are {{ clinic_hours }}."
})

Script.create({
  language: 'english',
  test_id: hepb_test.id,
  status_id: status_pending.id,
  message: "Your hepatitis B test result is still pending. Call back tomorrow to see if your hepatitis B result is ready."
})

Script.create({
  language: 'english',
  test_id: hepb_test.id,
  message: "I am not able to read your hepatitis B test results. You will have to come back to the clinic in order to get your hepatitis B test results. Clinic hours are {{ clinic_hours }}."
})

#######################
#     HEPATITIS C     #
#######################
Script.create({
  language: 'english',
  test_id: hepc_test.id,
  status_id: status_negative.id,
  message: "Your hepatitis C test was negative, which means that you probably do not have hepatitis C."
})

Script.create({
  language: 'english',
  test_id: hepc_test.id,
  status_id: status_positive.id,
  message: "Your hepatitis C test was positive, which means that you have been exposed to hepatitis C. You need further evaluation. Please return to the clinic. Clinic hours are {{ clinic_hours }}."
})

Script.create({
  language: 'english',
  test_id: hepc_test.id,
  status_id: status_pending.id,
  message: "Your hepatitis C test result is still pending. Call back tomorrow to see if your hepatitis C result is ready."
})

Script.create({
  language: 'english',
  test_id: hepc_test.id,
  message: "I am not able to read your hepatitis C test result. You will have to come back to the clinic in order to get your hepatitis C test results. Clinic hours are {{ clinic_hours }}."
})

#######################
#     DUMMY DATA      #
#######################
if Rails.env == "development"
  # Setup an array of all of our tests and there possible statuses.
  tests = [
    {test_id: chlamydia_test.id, statuses: [status_negative, status_positive_and_treated, status_pending, nil]},
    {test_id: gonorrhea_test.id, statuses: [status_negative, status_positive_and_treated, status_pending, nil]},
    {test_id: syphilis_test.id, statuses: [status_negative, status_positive_and_treated, status_pending, nil]},
    {test_id: hiv_test.id, statuses: [status_negative, status_pending, nil]},
    {test_id: hepb_test.id, statuses: [status_immune, status_need_vaccination, status_hepb_infected, status_pending, nil]},
    {test_id: hepc_test.id, statuses: [status_negative, status_positive, status_pending, nil]}
  ]

  # Create 100 visits for up to 10 different patients.
  100.times do |k|
    visited_on = rand(14.months.ago..Time.now)
    visit = Visit.create({
      patient_number: rand(10),
      clinic_id: (clinics.sample).id,
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
        positive: [status_positive, status_positive_and_treated, status_hepb_infected].include?(status),
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
