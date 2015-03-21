FactoryGirl.define do
  factory :visit do
    clinic_id { Clinic.all.sample.id }
    patient_number { Faker::Number.number(6).to_s }
    password { Faker::Number.number(10).to_s }
    username { Faker::Number.number(10).to_s }
    visited_on { Faker::Date.backward(180) }
  end
end