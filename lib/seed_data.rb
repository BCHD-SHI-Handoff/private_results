# Populates the DB with default clinics, tests, and statuses.
# This is moved out from the seeds.rb file in order to make testing easier.
# This way, the entire db can be wiped clean after every test.
module SeedData
  def self.populate
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
    status_positive_and_treated = Status.create(status: "Positive and treated")
    status_immune = Status.create(status: "Immune")
    status_need_vaccination = Status.create(status: "Need vaccination")
    status_hepb_infected = Status.create(status: "Hep B infected")

    status_pending = Status.create(status: "Pending")

    status_positive = Status.create(status: "Positive")
    status_come_back = Status.create(status: "Come back to clinic")

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
      name: 'phone_master',
      language: 'english',
      message: "You visited {{ clinic_name }} on {{ visit_date }} and were tested for {{ test_names }}.

{{ message }}


Thank you for calling!"
    })

    Script.create({
      name: 'online_master',
      language: 'english',
      message: "You visited {{ clinic_name }} on {{ visit_date }} and were tested for {{ test_names }}.

{{ message }}"
    })

    Script.create({
      name: 'pending',
      language: 'english',
      message: "Your test results are still pending. Please call back on {{ results_ready_on }} to get your test results."
    })

    Script.create({
      name: 'come_back',
      language: 'english',
      message: "One or more of your test results requires medical attention. Please come back to the clinic as soon as possible. The clinic hours are {{ clinic_hours }}."
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

  end
end