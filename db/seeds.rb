# frozen_string_literal: true

User.destroy_all

25.times do |i|
  User.create(
    email: Faker::Internet.email,
    password: 'Password1@',
    role: 0
  )
  system('clear') || system('cls')
  puts "Creating executor: #{i + 1}/25"
end

5.times do |i|
  User.create(
    email: Faker::Internet.email,
    password: 'Password1@',
    role: 1
  )
  system('clear') || system('cls')
  puts "Creating manager: #{i + 1}/5"
end
