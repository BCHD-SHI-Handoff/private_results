FactoryGirl.define do
  factory :clinic do
    code { ['C', 'D', "E", "TB", "U"].sample }

    # Choose name based off of code.
    name {
      {
        "C" => "Central Clinic",
        "D" => "Druid Clinic",
        "E" => "Eastern Clinic",
        "TB" => "TB Clinic",
        "U" => "Unknown"
      }[code]
    }
  end
end
