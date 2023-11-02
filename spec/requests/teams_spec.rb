# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'
require 'devise/jwt/test_helpers'

describe 'Teams' do
  let!(:manager) { create(:user, role: 1) }
  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers({},
                                          manager)
  end

  path '/api/v1/teams' do
    # CREATE
    post 'Create a team' do
      tags 'Teams'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :team_data, in: :body, schema: {
        type: :object,
        properties: {
          team: {
            type: :object,
            properties: {
              name: { type: :string, default: 'Team name' },
              description: { type: :string, default: 'Description' },
              manager_ids: {
                type: :array,
                properties: [
                  type: :integer
                ]
              },
              executor_ids: {
                type: :array,
                properties: [
                  type: :integer
                ]
              }
            },
            required: %w[name description]
          }
        }
      }

      response '201', 'correct request' do
        let(:team_data) { { team: attributes_for(:team) } }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        schema type: :object,
               properties: {
                 team: { type: :object,
                         properties: {
                           id: { type: :integer },
                           name: { type: :string },
                           description: { type: :string },
                           created_at: { type: :datetime },
                           updated_at: { type: :datetime }
                         } }
               }
        example 'application/json', :team, {
          "id": 7,
          "name": 'myTeam',
          "description": 'This is a great team',
          "created_at": '2023-10-07T06:08:03.427Z',
          "updated_at": '2023-10-07T06:08:03.427Z'
        }

        it 'creates new user for valid parameters' do
          expect do
            post api_v1_teams_path,
                 params: team_data,
                 headers: auth_headers
          end.to change { Team.count }.from(1).to(2)
        end

        run_test!
      end

      response '422', 'invalid request' do
        let(:team_data) { { team: attributes_for(:team, name: '') } }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        schema type: :object,
               properties: {
                 name: { type: :array,
                         properties: {
                           type: :string
                         } },
                 description: { type: :array,
                                properties: {
                                  type: :string
                                } }
               }

        example 'application/json', :team,
                {
                  "name": [
                    "can't be blank",
                    'is too short (minimum is 2 characters)'
                  ],
                  "description": [
                    'is too short (minimum is 3 characters)'
                  ]
                }

        it "doesn't create a new team for invalid parameters" do
          expect do
            post user_registration_path,
                 params: team_data,
                 headers: auth_headers
          end.not_to(change { Team.count })
        end

        run_test!
      end
    end

    # INDEX
    get 'Return a list of teams' do
      tags 'Teams'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'correct request' do
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        let!(:team) { create(:team, managers: [manager]) }
        let!(:other_team) { create(:team, managers: [manager]) }
        schema  type: :array,
                properties: [
                  { type: :object,
                    properties: {
                      id: { type: :integer },
                      name: { type: :string },
                      description: { type: :string },
                      created_at: { type: :datetime },
                      updated_at: { type: :datetime }
                    } }
                ]

        example 'application/json', :teams, [
          {
            "id": 7,
            "name": 'myTeam',
            "description": 'This is a great team',
            "created_at": '2023-10-07T06:08:03.427Z',
            "updated_at": '2023-10-07T06:08:03.427Z'
          }
        ]

        it 'returns a list of teams for a user' do
          get api_v1_teams_path,
              headers: auth_headers
          expect(response.body).to eq(manager.teams.to_json)
        end

        run_test!
      end
    end
  end

  path '/api/v1/teams/{id}' do
    let!(:team) { create(:team, managers: [manager]) }
    let(:other_manager) { create(:user, role: 1) }
    let!(:other_team) { create(:team, managers: [other_manager]) }

    # SHOW
    get 'Return a team' do
      tags 'Teams'
      security [bearer_auth: []]
      produces 'application/json'
      parameter name: :id, in: :path, schema: { type: :integer, default: 12 }

      response '200', 'correct request' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 description: { type: :string },
                 created_at: { type: :datetime },
                 updated_at: { type: :datetime }
               }

        example 'application/json', :team,
                {
                  "id": 7,
                  "name": 'myTeam',
                  "description": 'This is a great team',
                  "created_at": '2023-10-07T06:08:03.427Z',
                  "updated_at": '2023-10-07T06:08:03.427Z'
                }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        let(:id) { team.id }

        it 'returns a team for a correct user' do
          get api_v1_team_path(team.id),
              headers: auth_headers

          expect(response.body).to eq(team.to_json)
        end

        run_test!
      end

      response '401', 'unauthorized request' do
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        let(:id) { other_team.id }

        it "doesn't return a team for an incorrect user" do
          get api_v1_team_path(other_team.id),
              headers: auth_headers

          expect(response.body).to eq(' ')
        end
        run_test!
      end
    end

    # UPDATE
    patch 'Create a team' do
      tags 'Teams'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :team_data, in: :body, schema: {
        type: :object,
        properties: {
          team: {
            type: :object,
            properties: {
              name: { type: :string, default: 'Team name' },
              description: { type: :string, default: 'Description' },
              manager_ids: {
                type: :array,
                properties: [
                  type: :integer
                ]
              },
              executor_ids: {
                type: :array,
                properties: [
                  type: :integer
                ]
              }
            },
            required: %w[managers_ids]
          }
        }
      }
      parameter name: :id, in: :path, schema: { type: :integer, default: 12 }

      response '200', 'correct request' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 description: { type: :string },
                 created_at: { type: :datetime },
                 updated_at: { type: :datetime }
               }

        example 'application/json', :team,
                {
                  "id": 7,
                  "name": 'myTeam',
                  "description": 'This is a great team',
                  "created_at": '2023-10-07T06:08:03.427Z',
                  "updated_at": '2023-10-07T06:08:03.427Z'
                }

        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        let(:id) { team.id }
        let(:team_data) do
          { team: attributes_for(:team, manager_ids: [manager.id]) }
        end

        it 'returns a team for a correct user' do
          patch api_v1_team_path(team.id),
                params: team_data,
                headers: auth_headers

          team.reload
          expect(response.body).to eq({
            name: team_data[:team][:name],
            description: team_data[:team][:description],
            id: team.id,
            created_at: team.created_at,
            updated_at: team.updated_at
          }.to_json)
        end

        run_test!
      end

      response '403', 'forbidden request' do
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        let(:id) { other_team.id }
        let(:team_data) do
          { team: attributes_for(:team, manager_ids: [manager.id]) }
        end

        it 'returns a team for a correct user' do
          patch api_v1_team_path(other_team.id),
                params: team_data,
                headers: auth_headers

          expect(response.body).to eq(
            '{"error":"You are not authorized to perform this action"}'
          )
        end

        run_test!
      end

      response '422', 'incorrect request' do
        schema type: :object,
               properties: {
                 errors: { type: :array,
                           properties: {
                             type: :string
                           } }
               }

        example 'application/json', :team,
                {
                  "name": [
                    "can't be blank",
                    'is too short (minimum is 2 characters)'
                  ],
                  "description": [
                    'is too short (minimum is 3 characters)'
                  ]
                }

        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        let(:id) { team.id }
        let(:team_data) do
          { team: attributes_for(:team, name: '', manager_ids: [manager.id]) }
        end

        it 'returns a team for a correct user' do
          patch api_v1_team_path(team.id),
                params: team_data,
                headers: auth_headers

          expect(response.body).to eq(
            # rubocop:todo Layout/LineLength
            "{\"name\":[\"can't be blank\",\"is too short (minimum is 2 characters)\"]}"
            # rubocop:enable Layout/LineLength
          )
        end

        run_test!
      end

      # DESTROY
      delete 'Create a team' do
        tags 'Teams'
        security [bearer_auth: []]
        parameter name: :id, in: :path, schema: { type: :integer, default: 12 }

        response '204', 'correct request' do
          let(:Authorization) do
            Devise::JWT::TestHelpers.auth_headers({},
                                                  manager)['Authorization']
          end
          let(:id) { team.id }

          it 'deletes a team for a correct user' do
            other_auth_headers = Devise::JWT::TestHelpers
                                 .auth_headers({},
                                               other_manager)
            expect do
              delete api_v1_team_path(other_team.id),
                     headers: other_auth_headers
            end.to change { Team.count }.from(1).to(0)
          end

          run_test!
        end
      end
    end
  end
end
