FactoryGirl.define do
  factory :clinic do
    name { Faker::Address.street_name + " Clinic" }
    code { Faker::Lorem.characters(2).upcase }
    hours_in_english "Monday to Friday, 9am to 5pm"
    hours_in_spanish "Lunes a Viernes, 9am a 5pm"
  end
end
