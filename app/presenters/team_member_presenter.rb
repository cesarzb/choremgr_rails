# frozen_string_literal: true

class TeamMemberPresenter # rubocop:todo Style/Documentation
  # Doesn't inherit from anything
  def initialize(member)
    @member = member
  end

  def call
    {
      id:,
      email:
    }
  end

  attr_reader :member

  def id
    @member.id
  end

  def email
    @member.email
  end
end
