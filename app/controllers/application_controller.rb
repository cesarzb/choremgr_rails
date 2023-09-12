# frozen_string_literal: true

include ActionController::MimeResponds # rubocop:todo Style/MixinUsage

class ApplicationController < ActionController::API # rubocop:todo Style/Documentation
  respond_to :json
end
