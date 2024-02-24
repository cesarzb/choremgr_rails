# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'bootsnap', require: false
gem 'devise'
gem 'devise-jwt'
gem 'faker'
gem 'pagy'
gem 'pg', '~> 1.1'
gem 'puma'
gem 'rack-cors'
gem 'rails', '~> 7.0.6'
gem 'rswag'
gem 'rubocop', require: false
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'pry', '~> 0.14.2'
  gem 'pry-nav'
  gem 'pry-remote'
  gem 'rspec-rails', '~> 6.0.0'
end

group :development do
end

gem 'dockerfile-rails', '>= 1.6', group: :development
