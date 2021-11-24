# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'

gem 'aasm'
gem 'activerecord-postgis-adapter'
gem 'active_storage_validations'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', '>= 1.4.4', require: false # Reduces boot times through caching; required in config/boot.rb
gem 'chartkick'
gem 'devise'
gem 'faker', '~> 1.6', '>= 1.6.3'
gem 'geocoder', '~> 1.6', '>= 1.6.3'
gem 'groupdate'
gem 'haml-rails', '~> 2.0'
gem 'httparty'
gem 'image_processing', '~> 1.2'
gem 'jbuilder', '~> 2.7'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rack-cors'
gem 'rails', '~> 6.1.3', '>= 6.1.3.2'
gem 'redis', '~> 4.0'
gem 'rpush'
gem 'sass-rails'
gem 'simple_command'
gem 'will_paginate'

gem "rack-livereload", group: :development

group :development, :test do
  gem 'pry'
  gem 'factory_bot_rails'
  gem 'rubocop'
  gem 'guard-rspec', require: false
end

group :test do
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring' #  Read more: https://github.com/rails/spring
  gem 'guard-livereload', '~> 2.5', require: false
end
