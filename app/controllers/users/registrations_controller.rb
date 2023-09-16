# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController # rubocop:todo Style/Documentation
    before_action :configure_sign_up_params
    respond_to :json

    protected

    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
    end

    private

    def respond_with(resource, _opts = {})
      register_success && return if resource.persisted?

      register_failed(resource)
    end

    def register_success
      render json: { message: 'Registered.' }
    end

    def register_failed(resource)
      render json: { message: "Couldn't register.",
                     errors: resource.errors.full_messages },
             status: :unprocessable_entity
    end
  end
end
