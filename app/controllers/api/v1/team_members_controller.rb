# frozen_string_literal: true

module Api
  module V1
    # Controller for returning lists of team members
    class TeamMembersController < ApplicationController
      before_action :authenticate_user!

      def managers_list
        render json: User.where(role: :manager) do |user|
          member = ::TeamMemberPresenter.new(user)
          member.call
        end
      end

      def users_list
        render json: User.all.each do |user|
          member = ::TeamMemberPresenter.new(user)
          member.call
        end
      end
    end
  end
end
