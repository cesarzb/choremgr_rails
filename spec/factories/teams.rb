# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    name { Faker::FunnyName.name }
    description { Faker::JapaneseMedia::StudioGhibli.quote }
  end
end
