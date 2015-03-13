FactoryGirl.define do
  factory :test do
    name { ["Chlamydia", "Gonorrhea", "Syphilis", "HIV", "Hepatitis B", "Hepatitis C"].sample }
  end
end
