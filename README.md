# Private Results
Private Results enables clinics to provide patients a way to get their test results via phone or online.

## Workflow
1. Patient visits a clinic and gets some tests done.
2. Clinic hands patient a card with phone number, website, username and password for Private Results.
3. Clinic imports patient_data.csv into Private Results (providing visit and test result info).
4. Patient calls Private Results and enters the username and password they were provided.
5. Private Results looks up the username and password and delivers the results.

The results provided are dependant on the status of each test result and follows the following logic:
```ruby
# Found in app/models/visit.rb
if results.any?{ |result| result.status.nil? || result.status == "Come back to clinic" }
  message = "Come back to the clinic"
elsif results.any?{ |result| result.status == "Pending" } and visited_on > 7.days.ago
  message = "Your test results are still pending, call back..."
else
  message = results.messages.join("\n")
end
```

This ensures that if any test result does not have a status or has the status **"Come back to clinic"**,
the patient will not receive any of their results and will instead be instructed to come back to the clinic.
Similarly, if any test result is still **"Pending"**, and the patient's visit was recent (less than 7 days ago),
then the patient will be told to call back. If neither of those cases is true, then we deliver each test result to the patient.

## Dependencies
* Rails 4.1.8
* Ruby 2.1.5
* [PhantomJS](https://github.com/teampoltergeist/poltergeist#installing-phantomjs) (for testing)
* Postgres
* [Twilio](https://twilio.com/) Account

## Development

Private Results is well tested, please run `rspec spec` from the top directory in order to make sure everything is working as it should.

The seeds file contains clinics, tests, scripts and statuses that are needed by Private Results.

The test suite follows the following templates for model and controller testing:
* [Rspec model testing template](https://gist.github.com/kyletcarlson/6234923)
* [Rspec controller testing template](https://gist.github.com/eliotsykes/5b71277b0813fbc0df56)

We use the [Twilio test toolkit](https://www.twilio.com/blog/2012/10/twilio-test-toolkit.html) to help us unit test our twilio views.

To test and develop with twilio, you'll need someway to allow twilio to connect to your local instance at localhost:3000. 
[ngrok](https://ngrok.com/) is an awesome way to do this!


## Deploying & Running
#### Deployment:
1. Download Private Results and run rails server:
```
git clone https://github.com/wes-r/private_results
cd private_results
bundle install
rake db:setup
rake assets::precompile RAILS_ENV=production
rails s -e production
```
2. Point a domain at your rails server's ip:port
3. Point twilio at your domain.

#### Running:
You'll need to run `rake import:csv patient_data.csv` in order to import patient data.
