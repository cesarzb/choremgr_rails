# frozen_string_literal: true

include ActionController::MimeResponds # rubocop:todo Style/MixinUsage

# class for Application Controller, that all other components inherit from
class ApplicationController < ActionController::API
  include Pagy::Backend

  respond_to :json
end
