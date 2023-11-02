# frozen_string_literal: true
FactoryBot.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user do
    email
    password { 'Password1@' }
    password_confirmation { 'Password1@' }
    role { 'executor' }
  end
end
