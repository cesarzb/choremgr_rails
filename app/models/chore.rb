# frozen_string_literal: true

# model for chore
class Chore < ApplicationRecord
  scope :for_user, lambda { |user|
                     where(manager_id: user.id).or(where(executor_id: user.id))
                   }
  scope :for_teams, lambda { |team_ids|
                      where(team_id: team_ids) if team_ids.present?
                    }
  belongs_to :manager, class_name: 'User', foreign_key: :manager_id
  belongs_to :executor, class_name: 'User', foreign_key: :executor_id
  belongs_to :team
  has_many :chore_executions

  validates :name, presence: true, length: { minimum: 2, maximum: 24 }
  validates :description, length: { minimum: 3 }
  validates :manager_id, presence: true
  validates :executor_id, presence: true
  validates :team_id, presence: true
end
