FactoryBot.define do
  factory :chore do
    name { Faker::FunnyName.name.slice(0..23) }
    description { Faker::JapaneseMedia::StudioGhibli.quote.slice(0..100) }
  end
end
