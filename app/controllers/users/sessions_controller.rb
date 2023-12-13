# frozen_string_literal: true

module Users
  # controller responsible for handling user session logic
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(_resource, _opts = {})
      render json: {
               message: 'Logged in.',
               role: current_user.role,
               id: current_user.id
             },
             status: :ok
    end

    def respond_to_on_destroy
      log_out_success && return if current_user

      log_out_failure
    end

    def log_out_success
      render json: { message: 'Logged out.' }, status: :ok
    end

    def log_out_failure
      render json: { message: "Couldn't log out." }, status: :unauthorized
    end
  end
end
