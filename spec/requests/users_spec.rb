# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

describe 'Users' do
  path '/users' do
    post 'Create a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :signup_data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, default: 'email@example.com' },
              password: { type: :string, default: 'Password1@' },
              password_confirmation: { type: :string, default: 'Password1@' },
              role: { type: :integer, default: 0 }
            },
            required: %w[email password password_confirmation role]
          }
        }
      }

      response '200', 'creates a user' do
        let(:signup_data) { { user: attributes_for(:user) } }
        schema type: :object,
               properties: {
                 message: { type: :string }
               }
        header 'Authorization', schema: { type: :string, nullable: false },
                                description: 'JWT token that is required to
                                proceed to other pages authorized,
                          it looks like this: "Authorization: Bearer
                          generated.jwt.token"'

        example 'application/json', :user, {
          "message": 'Registered.'
        }
        run_test!
      end

      response '422', 'invalid request' do
        let(:signup_data) { { user: attributes_for(:user, password: ' ') } }
        run_test!
      end
    end
  end

  path '/users/sign_in' do
    let!(:mgr_user) { create(:user, role: 1) }
    let!(:exe_user) { create(:user, role: 0) }

    post 'Log in a user' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :signin_data, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string }
            }
          },
          required: %w[email password password_confirmation role]
        }
      }

      response '200', 'user logged in' do
        let(:signin_data) do
          { user: { email: exe_user.email,
                    password: exe_user.password } }
        end
        run_test!
      end

      response '401', 'user unauthorized' do
        let(:signin_data) do
          { user: { email: exe_user.email,
                    password: "#{exe_user.password} wrong" } }
        end
        run_test!
      end
    end
  end
end
