class TeamPresenter
  # Doesn't inherit from anything
  def initialize(team)
    @team = team
  end

  def call
    {
      id:,
      name:,
      description:,
      created_at:,
      updated_at:,
      managers:,
      executors:
    }
  end

  attr_reader :team

  def managers
    @team.managers.map do |manager|
      member_presenter = TeamMembersPresenter.new(manager)
      member_presenter.call
    end
  end

  def executors
    @team.executors.map do |executor|
      member_presenter = TeamMembersPresenter.new(executor)
      member_presenter.call
    end
  end

  def id
    @team.id
  end

  def name
    @team.name
  end

  def description
    @team.description
  end

  def created_at
    @team.created_at
  end

  def updated_at
    @team.updated_at
  end
end
