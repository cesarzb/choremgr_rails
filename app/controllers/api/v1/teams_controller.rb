# frozen_string_literal: true

module Api
  module V1
    # rubocop:todo Style/Documentation
    class TeamsController < ApplicationController
      # rubocop:enable Style/Documentation
      before_action :authenticate_user!
      before_action :set_team, only: %i[show update destroy]
      before_action :manager?, only: %i[create update destroy]
      before_action :team_manager?, only: %i[update destroy]
      before_action :build_team_with_params, only: :create

      def create
        build_team_with_params

        if @team.save
          render json: @team, status: :created
        else
          render json: @team.errors, status: :unprocessable_entity
        end
      end

      def index
        @teams = current_user.teams
        render json: @teams
      end

      def show
        if current_user.teams.include?(@team)
          render json: @team
        else
          render status: :unauthorized
        end
      end

      def update
        ActiveRecord::Base.transaction do
          @team.executor_ids = params.dig(:team, :executor_ids)
          @team.manager_ids = params.dig(:team, :manager_ids)
          if @team.update(team_params)
            render json: @team
          else
            render json: @team.errors, status: :unprocessable_entity
            raise ActiveRecord::Rollback # Roll back the transaction
          end
        end
      end

      def destroy
        if @team.destroy
          render head: :no_content
        else
          render head: :unprocessable_entity
        end
      end

      private

      def set_team
        @team = Team.find(params[:id])
        return if @team

        render json: { error: 'Team not found' },
               status: :not_found
      end

      def team_params
        params.require(:team).permit(:name, :description)
      end

      def manager?
        return if current_user.manager?

        render json: { error: 'You are not authorized to perform this action' },
               status: :forbidden
      end

      def team_manager?
        return if @team.managers.include?(current_user)

        render json: { error: 'You are not authorized to perform this action' },
               status: :forbidden
      end

      def build_team_with_params
        @team = Team.new(team_params)
        @team.manager_ids = params.dig(:team, :manager_ids)
        @team.executor_ids = params.dig(:team, :executor_ids)
        @team.managers << current_user
      end
    end
  end
end
