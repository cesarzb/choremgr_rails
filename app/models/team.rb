# frozen_string_literal: true

class Team < ApplicationRecord # rubocop:todo Style/Documentation
  has_and_belongs_to_many :managers, class_name: 'User',
                                     join_table: :user_team_managed,
                                     validate: false

  has_and_belongs_to_many :executors, class_name: 'User',
                                      join_table: :user_team_executed,
                                      validate: false
  has_many :chores, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 24 }
  validates :description, length: { minimum: 3 }
  validate :manager_present

  def members
    managers + executors
  end

  private

  def manager_present
    return unless managers.empty?

    errors.add :managers,
               'has to contain at least one manager.'
  end
end
