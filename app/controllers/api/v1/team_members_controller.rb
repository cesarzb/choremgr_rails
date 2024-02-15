# frozen_string_literal: true

module Api
  module V1
    # Controller for returning lists of team members
    class TeamMembersController < ApplicationController
      before_action :authenticate_user!
      before_action :manager?

      def managers_list
        if params[:team_id].present?
          team_manager?
          manager_users = Team.find(params[:team_id]).managers
        else
          manager_users = User.where(role: :manager)
        end

        render json: manager_users.each do |user|
          member = ::TeamMemberPresenter.new(user)
          member.call
        end
      end

      def users_list
        if params[:team_id].present?
          team_manager?
          executor_users = Team.find(params[:team_id]).executors
        else
          executor_users = User.all
        end

        render json: executor_users.each do |user|
          member = ::TeamMemberPresenter.new(user)
          member.call
        end
      end

      private

      def manager?
        return if current_user.manager?

        render json: { error: 'You are not a manager!' },
               status: :forbidden
      end

      def team_manager?
        unless current_user.managed_teams.include?(Team.find(params[:team_id]))
          render json:
          { error: 'You are not a manager of this team!' },
                 status: :forbidden

        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'You are not a manager of this team!' },
               status: :forbidden
      end
    end
  end
end
