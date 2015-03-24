FactoryGirl.define do
  factory :visit do
    clinic_id { Clinic.all.sample.id }
    patient_number { Faker::Number.number(6).to_s }
    password { Faker::Number.number(10).to_s }
    username { Faker::Number.number(10).to_s }
    visited_on { Faker::Date.backward(180) }

    factory :visit_with_results do
      transient do
        results_count { rand(2..4) }
      end

      after(:create) do |visit, evaluator|
        create_list(:result, evaluator.results_count, visit: visit)
      end
    end
  end
end