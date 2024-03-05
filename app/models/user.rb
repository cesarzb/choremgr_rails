# frozen_string_literal: true

# this is a User model class
# User objects are as the name suggests users of this app
# they can be either managers or executors
# they can execute tasks or manage team, or do both this things at once
class User < ApplicationRecord
  has_and_belongs_to_many :managed_teams, class_name: 'Team',
                                          join_table: :user_team_managed
  has_and_belongs_to_many :executed_teams, class_name: 'Team',
                                           join_table: :user_team_executed
  has_many :chores, dependent: :destroy, foreign_key: :manager_id
  has_many :chores, dependent: :destroy, foreign_key: :executor_id
  has_many :chore_executions, through: :chores

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  validates :role, presence: true
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: true
  validates :password, presence: true,
                       confirmation: true
  validates :password_confirmation, presence: true
  validate :strong_password
  enum role: %i[executor manager]

  def teams
    (managed_teams.all + executed_teams.all).uniq
  end

  def teams_with_managers_or_executors
    Team
      .joins('LEFT JOIN user_team_managed ON user_team_managed.team_id =
      teams.id')
      .joins('LEFT JOIN user_team_executed ON user_team_executed.team_id =
      teams.id')
      .where('user_team_managed.user_id = ? OR user_team_executed.user_id = ?',
             id, id)
      .distinct

    # SELECT DISTINCT teams.*
    # FROM teams
    # LEFT JOIN user_team_managed ON user_team_managed.team_id = teams.id
    # LEFT JOIN user_team_executed ON user_team_executed.team_id = teams.id
    # WHERE user_team_managed.user_id = :user_id OR user_team_executed.user_id
    # = :user_id
  end

  private

  def strong_password
    return unless password.present?

    password_long_enough?

    password_too_long?

    password_has_digit?

    password_has_uppercase?

    password_has_lowercase?

    password_has_special_character?
  end

  def password_long_enough?
    return if password.length >= 8

    errors.add(:password, 'must be at least 12 characters long')
  end

  def password_too_long?
    return if password.length < 17

    errors.add(:password, "can't be longer than 16 characters")
  end

  def password_has_digit?
    return if password.match?(/\d/)

    errors.add(:password, 'must contain at least one digit (0-9)')
  end

  def password_has_uppercase?
    return if password.match?(/[A-Z]/)

    errors.add(:password, 'must contain at least one uppercase letter')
  end

  def password_has_lowercase?
    return if password.match?(/[a-z]/)

    errors.add(:password, 'must contain at least one lowercase letter')
  end

  def password_has_special_character?
    return if password.match?(/[!@#$%^&*(),.?":{}|<>]/)

    errors.add(:password,
               'must contain at least one special character' \
               '(!@#$%^&*(),.?":{}|<>)')
  end
end
