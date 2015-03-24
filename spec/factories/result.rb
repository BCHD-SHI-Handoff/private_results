FactoryGirl.define do
  factory :result do
    visit
    test_id { Test.all.sample.id }

    # Make sure to grab a status which makes sense for the given test.
    # For example a status of "immune" does not work with a test of "Chlamydia".
    status_id { Script.where(test_id: test_id).all.sample.status_id }

    # Results will probably be recorded up to 5 days after visit.
    recorded_on { Faker::Date.between(visit.visited_on, visit.visited_on + 5.days) }
  end
end
