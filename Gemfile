ruby '2.1.5'
source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'

# Provides common translations for different languages
gem 'rails-i18n', '~> 4.0.0'

# Use postgres as the database for Active Record
gem 'pg'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem 'sass-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Authentication library
gem 'devise', '~> 3.4.1'

# Simple form to make building our front-end forms easier
gem 'simple_form', '~> 3.1.0'

# Use growly flash for XHR alerts
gem 'growlyflash', '~> 0.6.0'

# We use twilio to receive calls
gem 'twilio-ruby', '~> 3.12'

# We use liquid templates for message scripts
gem 'liquid', '~> 3.0.1'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'bootstrap-datepicker-rails'

# Use newrelic for monitoring.
gem 'newrelic_rpm'

# Makes dealing with soft deletes a lot easier.
gem "paranoia", "~> 2.0"

group :test do
  gem "factory_girl_rails", "~> 4.0"
  gem 'rspec-rails', '~> 3.0'
  gem "faker", "~> 1.4.3"
  gem 'rack_session_access'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'selenium-webdriver' # Currently not being used.
  gem 'poltergeist'
  gem 'twilio-test-toolkit'
  gem 'shoulda-matchers'
  gem 'shoulda-callback-matchers'
end
