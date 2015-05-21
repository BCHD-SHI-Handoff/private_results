# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'factory_girl_rails'
require 'capybara/rails'
require 'capybara-screenshot/rspec'
require 'capybara/poltergeist'
require 'selenium-webdriver'
require "rack_session_access/capybara"
require 'devise'
require 'helpers'

# Setup warden so our feature tests can login quickly (without login form).
include Warden::Test::Helpers
Warden.test_mode!

# Setup capybara to use the poltergeist (phatomJS) runner.
Capybara.javascript_driver = :poltergeist
# Below is how to use the chrome driver instead,
# This can be useful for watching the tests playout in a chrome browser.
# Capybara.register_driver :chrome do |app|
#   Capybara::Selenium::Driver.new(app, :browser => :chrome)
# end
# Capybara.javascript_driver = :chrome

Capybara.default_wait_time = 10

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# We need to use DatabaseCleaner as our selenium tests require
# us to turn off use_transactional_fixtures.
# See http://stackoverflow.com/q/6154687 for details.
DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.include Helpers
  config.include Devise::TestHelpers, :type => :controller

  config.after :each do
    Warden.test_reset!
  end

  # Using the shortened version of FactoryGirl syntax.
  config.include FactoryGirl::Syntax::Methods

  # Configure Twilio Test Toolkit
  config.include TwilioTestToolkit::DSL, :type => :feature

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.before :each do
    # Create our default user.
    # Note: Normally we would also include this in the seeds file,
    # however the DatabaseCleaner truncation, wipes the user table clean.
    @default_user = User.create(
      email: DEFAULT_USER_EMAIL, # Found in config/initializers/constants.rb
      password: DEFAULT_USER_PASSWORD,
      password_confirmation: DEFAULT_USER_PASSWORD,
      role: :admin,
      active: true
    )
    @default_user.confirm!

    # Load our clinics, tests and scripts.
    # Unfortunately this slows our unit tests but it allows our tests
    # to modify these three models.
    SeedData::populate()

    DatabaseCleaner.start
  end
  config.after :each do
    DatabaseCleaner.clean
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end
