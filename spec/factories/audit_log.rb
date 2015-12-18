FactoryGirl.define do
  factory :audit_log do
    user_id { Faker::Number.number(2) }
    user_email { Faker::Internet.safe_email }
    if (Random.rand(2))
      viewed_patient_number { Faker::Number.number(6).to_s }
    else
      viewed_csv_start_date { Faker::Date.between(180.days.ago, 90.days.ago) }
      viewed_csv_end_date { Faker::Date.between(90.days.ago, Date.today) }
    end
  end
end