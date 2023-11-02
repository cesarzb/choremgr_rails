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

      response '200', 'correct request' do
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

        it 'creates new user for valid parameters' do
          expect do
            post user_registration_path,
                 params: { user: attributes_for(:user) }
          end.to change { User.count }.from(0).to(1)
        end

        it 'has a successful response' do
          post user_registration_path,
               params: { user: attributes_for(:user) }
          expect(response.status).to eq(200)
        end
      end

      response '422', 'invalid request' do
        let(:signup_data) { { user: attributes_for(:user, password: ' ') } }
        schema type: :object,
               properties: {
                 message: { type: :string },
                 errors: { type: :array,
                           properties: {
                             type: :string
                           } }
               }

        example 'application/json', :user,
                {
                  "email": [
                    "can't be blank"
                  ]
                }

        it "doesn't create new user for invalid parameters" do
          expect do
            post user_registration_path,
                 params: { user: attributes_for(:user, password: ' ') }
          end.not_to(change { User.count })
        end

        it "doesn't have a successful response" do
          post user_registration_path,
               params: { user: attributes_for(:user, password: ' ') }
          expect(response.status).to eq(422)
        end
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
        schema type: :object,
               properties: {
                 message: { type: :string }
               }
        header 'Authorization', schema: { type: :string, nullable: false },
                                description: 'JWT token that is required to
                                proceed to other pages authorized,
                          it looks like this: "Authorization: Bearer
                          generated.jwt.token"'
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
