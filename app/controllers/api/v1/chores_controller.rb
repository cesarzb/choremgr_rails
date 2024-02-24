# frozen_string_literal: true

module Api
  module V1
    # Controller class for chores
    class ChoresController < ApplicationController
      before_action :authenticate_user!
      before_action :set_chore, only: %i[show update destroy]
      before_action :manager?, only: %i[create update destroy]
      before_action :team_manager?, only: :create
      before_action :team_member?, only: :create
      before_action :chore_manager?, only: %i[update destroy]
      before_action :build_chore_with_params, only: :create
      after_action { pagy_headers_merge(@pagy) if @pagy }

      def create
        build_chore_with_params

        if @chore.save
          chore_presenter = ::ChorePresenter.new(@chore)
          render json: chore_presenter.call, status: :created
        else
          render json: @chore.errors, status: :unprocessable_entity
        end
      end

      def index
        @chores = Chore.for_user(current_user).for_teams(params[:team_ids])
        @pagy, @chores = pagy(@chores)

        render json: @chores
      end

      def show
        if Chore.for_user(current_user).include?(@chore)
          chore_presenter = ::ChorePresenter.new(@chore)
          render json: chore_presenter.call
        else
          render status: :unauthorized
        end
      end

      def update
        ActiveRecord::Base.transaction do
          return unless assign_members

          if @chore.update(chore_params)
            chore_presenter = ::ChorePresenter.new(@chore)
            render json: chore_presenter.call
          else
            render json: @chore.errors, status: :unprocessable_entity
            raise ActiveRecord::Rollback
          end
        end
      end

      def destroy
        @chore.destroy
        render status: :no_content
      end

      private

      def set_chore
        @chore = Chore.find(params[:id])
        return if @chore

        render json: { error: 'Chore not found' },
               status: :not_found
      end

      def chore_params
        params.require(:chore).permit(:name, :description)
      end

      def manager?
        return if current_user.manager?

        render json: { error: 'You are not a manager!' },
               status: :forbidden
      end

      def chore_manager?
        return if @chore.manager_id == current_user.id

        render json: { error: 'You are not the manager of this chore!' },
               status: :forbidden
      end

      def build_chore_with_params
        @chore = Chore.new(chore_params)
        @chore.executor_id = params.dig(:chore, :executor_id)
        @chore.manager_id = current_user.id
        @chore.team_id = params[:team_id]
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

      def team_member?
        team = Team.find(params[:team_id])
        unless team.executors.include?(User.find(params.dig(:chore,
                                                            :executor_id)))
          render json: { error: 'You are not a member of this team!' },
                 status: :forbidden
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'You are not a member of this team!' },
               status: :forbidden
      end

      def assign_members
        @chore.manager_id = params.dig(:chore, :manager_id)
        @chore.executor_id = params.dig(:chore, :executor_id)

        !@chore.manager_id.nil? && !@chore.executor_id.nil?
      end
    end
  end
end
