# frozen_string_literal: true

class Chore < ApplicationRecord # rubocop:todo Style/Documentation
  scope :for_user, lambda { |user|
                     where(manager_id: user.id).or(where(executor_id: user.id))
                   }
  scope :for_teams, lambda { |team_ids|
                      where(team_id: team_ids) if team_ids.present?
                    }
  belongs_to :manager, class_name: 'User'
  belongs_to :executor, class_name: 'User'
  belongs_to :team

  validates :name, presence: true, length: { minimum: 2, maximum: 24 }
  validates :description, length: { minimum: 3 }
  validates :manager_id, presence: true
  validates :executor_id, presence: true
  validates :team_id, presence: true
end
