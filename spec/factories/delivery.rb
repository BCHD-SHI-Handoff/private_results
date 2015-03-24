FactoryGirl.define do
  factory :delivery do
    delivered_at { Faker::Date.backward(180) }
    delivery_method { ["phone", "online"].sample }
    message { Faker::Lorem.paragraph }
    phone_number_used { delivery_method == "phone" ? "+1555" + Faker::Number.number(7) : nil }
  end
end