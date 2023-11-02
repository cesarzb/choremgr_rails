# frozen_string_literal: true

class User < ApplicationRecord # rubocop:todo Style/Documentation
  has_and_belongs_to_many :managed_teams, class_name: 'Team',
                                          join_table: :user_team_managed
  has_and_belongs_to_many :executed_teams, class_name: 'Team',
                                           join_table: :user_team_executed
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  validates :role, presence: true
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: true
  validates :password, presence: true, length: { minimum: 6 },
                       confirmation: true
  validates :password_confirmation, presence: true

  enum role: %i[executor manager]

  def teams
    (managed_teams.all + executed_teams.all).uniq
  end
end
