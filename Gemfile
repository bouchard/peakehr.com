source 'https://rubygems.org'

gem 'rails', '~> 4.2'
gem 'redis-rails'
gem 'pg'
gem 'paper_trail'
gem 'prawn'
gem 'prawn-table'
gem 'state_machine'
gem 'delayed_job_active_record'
gem 'turbolinks'
gem 'cancan'
# Enable Tesseract down the road to do OCR.
# gem 'tesseract-ocr'
gem 'sitemap_generator'

# For has_secure_password.
gem 'bcrypt-ruby'

# One time password, and phone scan for API token.
gem 'active_model_otp'
gem 'rqrcode'

# Uploads. Imagemagick needs to be available.
gem 'paperclip'

## Assets. ##
gem 'eco'
gem 'sass-rails'
# gem 'sass-rails', github: 'rails/sass-rails', branch: '4-0-stable'
gem 'compass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'font-awesome-rails'
############

group :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'timecop'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'nokogiri' # For importing ICD10.
  gem 'web-console'
  gem 'rubyzip' # For unzipping and importing SNOMED CT.
end

group :test, :development do
  gem 'factory_girl_rails'
end

group :production do
  gem 'whenever', :require => false
  # For delayed_job.
  gem 'daemons'
end