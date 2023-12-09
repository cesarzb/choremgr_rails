# frozen_string_literal: true

module Api
  module V1
    # Controller class for chore execution
    class ChoreExecutionsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_chore
      before_action :set_chore_execution, only: :destroy
      before_action :chore_executor?, only: %i[create destroy]
      before_action :team_manager_or_chore_executor?, only: :index

      def create
        @chore_execution = ChoreExecution.new(chore: @chore,
                                              date: Time.now)
        if @chore_execution.save
          render json: { message: 'Congratulations, chore executed!' },
                 status: :created
        else
          render json: @chore_execution.errors, status: :unprocessable_entity
        end
      end

      def index
        @chore_executions = @chore.chore_executions.order(created_at: :desc)

        render json: @chore_executions, status: :ok
      end

      def destroy
        @chore_execution.destroy
        render status: :no_content
      end

      private

      def set_chore
        @chore = Chore.find(params[:chore_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Chore doesn't exist!" },
               status: :unprocessable_entity
      end

      def set_chore_execution
        @chore_execution = ChoreExecution.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Chore execution doesn't exist!" },
               status: :unprocessable_entity
      end

      def chore_executor?
        return if @chore.executor_id == current_user.id

        render json: { error: 'You are not the executor of this chore!' },
               status: :forbidden
      end

      def team_manager_or_chore_executor?
        return if @chore.team.managers.include?(current_user)

        chore_executor?
      end
    end
  end
end
