# frozen_string_literal: true

module Api
  module V1
    class TeamMembersController < ApplicationController
      before_action :authenticate_user!

      def managers_list
        render json: User.where(role: :manager) do |user|
          member = ::TeamMembersPresenter.new(user)
          member.call
        end
      end

      def users_list
        render json: User.all.each do |user|
          member = ::TeamMembersPresenter.new(user)
          member.call
        end
      end
    end
  end
end
