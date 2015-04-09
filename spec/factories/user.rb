FactoryGirl.define do
  factory :user do
    email { Faker::Internet.safe_email }
    role { [:admin, :staff].sample }
    active { [true, false].sample }
    password DEFAULT_USER_PASSWORD
    password_confirmation DEFAULT_USER_PASSWORD
    confirmed_at { Faker::Time.backward(7) }
  end
end
