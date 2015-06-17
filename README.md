# Private Results
Private Results provides a way for patients to get their test results via phone or the web. Currently, this project has hardcoded data (clinic info) for [BCHD](http://health.baltimorecity.gov/).

## LICENSE
Private Results is copyright © 2014-2015 [Sexual Health Innovations](http://www.sexualhealthinnovations.org/). It is free software, and may be redistributed under the terms specified in the [MIT-LICENSE](MIT-LICENSE.md) file.

## Workflow
1. Patient visits a clinic and gets some tests done.
2. Clinic hands patient a card with phone number, website, username and password for Private Results.
3. Clinic imports patient_data.csv into Private Results (providing visit and test result info).
4. Patient calls (or visits website) Private Results and enters the username and password they were provided.
5. Private Results looks up the username and password and delivers the results.

The results provided are dependant on the status of each test result and follows the following logic:
```ruby
# Found in app/models/visit.rb
if results.any?{ |result| result.status.nil? }
  message = "There was a technical problem reading one of your test results..."
elsif results.any?{ |result| result.status == "Come back to clinic" }
  message = "Come back to the clinic..."
elsif results.any?{ |result| result.status == "Pending" }
  message = "Your test results are still pending, call back..."
else
  message = results.messages.join("\n")
end
```

This ensures that if any test result is corrupt (has no status) then we report a technical issue and
instruct the patient to call the clinic. Similarly, if any result has the status **"Come back to clinic"**,
the patient will not receive any of their results and will instead be instructed to come back to the clinic.
Lastly, if any test result is still **"Pending"**, then the patient will be told to call back.
If neither of these cases is true, then we deliver each test result to the patient.

## Dependencies
* Rails 4.2.1
* Ruby 2.1.5
* [PhantomJS](https://github.com/teampoltergeist/poltergeist#installing-phantomjs) (for testing)
* Postgres
* [Twilio](https://twilio.com/) Account


## Development
Private Results is well tested, please run `rspec spec` from the top directory in order to make sure everything is working as it should.

Seed data has been split out into lib/seed_data.rb in order to make unit testing easier. This seed data contains the initial list of:
* Clinics - name, code, hours
* Tests - chlamydia, gonorrhea, etc
* Statuses - Pending, Come back to clinic, etc
* Scripts - the call-in workflow messages and test result messages 

The test suite follows the following templates for model and controller testing:
* [Rspec model testing template](https://gist.github.com/kyletcarlson/6234923)
* [Rspec controller testing template](https://gist.github.com/eliotsykes/5b71277b0813fbc0df56)

We use the [Twilio test toolkit](https://www.twilio.com/blog/2012/10/twilio-test-toolkit.html) to help us unit test our twilio views.

To test and develop with twilio, you'll need someway to allow twilio to connect to your local instance at localhost:3000. 
[ngrok](https://ngrok.com/) is an awesome way to do this!


## Deploying & Running
#### Deployment:
Note: You'll need to run the Private Results rails app on a server that can be accessed by the internet and that has access to a mail server (to send out account information to the administrators of Private Results).

* Download Private Results and run the rails server:
```
git clone https://github.com/wes-r/private_results
cd private_results
bundle install
rake db:setup
rake assets::precompile RAILS_ENV=production
rails s -e production
```
* Point a domain at your rails server's ip:port
* Point twilio at your domain.

#### Running:
You'll need to run `rake import:csv patient_data.csv` in order to import patient data.
