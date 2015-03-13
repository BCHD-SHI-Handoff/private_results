FactoryGirl.define do
  factory :status do
    status { ["Negative", "Positive", "Positive and treated", "Pending", "Immune", "Need vaccination", "Hep B infected"].sample }
  end
end
