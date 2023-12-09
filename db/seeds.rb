# frozen_string_literal: true

User.destroy_all

executors = []

25.times do |i|
  executors << User.create!(
    email: Faker::Internet.email,
    password: 'Password1@',
    password_confirmation: 'Password1@',
    role: 0
  )
  system('clear') || system('cls')
  puts "Creating executors: #{i + 1}/25"
end

managers = []

5.times do |i|
  managers << User.create!(
    email: Faker::Internet.email,
    password: 'Password1@',
    password_confirmation: 'Password1@',
    role: 1
  )
  system('clear') || system('cls')
  puts "Creating managers: #{i + 1}/5"
end

teams = []

5.times do |i|
  team = Team.new(
    name: Faker::FunnyName.name,
    description: Faker::JapaneseMedia::StudioGhibli.quote
  )

  team.managers << managers[i]

  5.times do |j|
    team.executors << executors[i * 5 + j]
  end

  teams << team.save

  system('clear') || system('cls')
  puts "Creating teams: #{i + 1}/5"
end

executors.each_with_index do |executor, index|
  3.times do |i|
    chore = Chore.create!(
      name: Faker::FunnyName.name,
      description: Faker::JapaneseMedia::StudioGhibli.quote,
      executor_id: executor.id,
      team_id: executor.teams.first.id,
      manager_id: executor.teams.first.managers.first.id
    )

    today = DateTime.now
    3.times do |num|
      ChoreExecution.create!(
        date: today.days_ago(num),
        chore: chore
      )
      system('clear') || system('cls')
      puts "For executor #{index + 1}/#{executors.size}\nCreating chores: #{i + 1}/3\nWith chore executions: #{num + 1}/3"
    end
  end
end
