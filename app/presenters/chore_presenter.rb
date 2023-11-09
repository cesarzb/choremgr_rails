# frozen_string_literal: true

class ChorePresenter # rubocop:todo Style/Documentation
  # Doesn't inherit from anything
  def initialize(chore)
    @chore = chore
  end

  def call
    {
      id:,
      name:,
      description:,
      created_at:,
      updated_at:,
      manager:,
      executor:,
      team:
    }
  end

  attr_reader :chore

  def manager
    TeamMemberPresenter.new(@chore.manager).call
  end

  def executor
    TeamMemberPresenter.new(@chore.executor).call
  end

  def team
    {
      id: @chore.team.id,
      name: @chore.team.name
    }
  end

  def id
    @chore.id
  end

  def name
    @chore.name
  end

  def description
    @chore.description
  end

  def created_at
    @chore.created_at
  end

  def updated_at
    @chore.updated_at
  end
end
