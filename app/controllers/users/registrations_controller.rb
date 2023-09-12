# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController # rubocop:todo Style/Documentation
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      register_success && return if resource.persisted?

      register_failed
    end

    def register_success
      render json: { message: 'Registered.' }
    end

    def register_failed
      render json: { message: "Couldn't register." }
    end
  end
end
