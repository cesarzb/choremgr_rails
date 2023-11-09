# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'
require 'devise/jwt/test_helpers'

describe 'Chores' do
  let!(:manager)  { create(:user, role: 1) }
  let!(:executor) { create(:user, role: 0) }
  let!(:team)     do
    create(:team, manager_ids: [manager.id], executor_ids: [executor.id])
  end
  let!(:other_manager)  { create(:user, role: 1) }
  let!(:other_executor) { create(:user, role: 0) }
  let!(:second_team) do
    create(:team, manager_ids: [manager.id], executor_ids: [other_executor.id])
  end
  let!(:other_team) do
    create(:team, manager_ids: [other_manager.id],
                  executor_ids: [other_executor.id])
  end

  let(:auth_headers) do
    Devise::JWT::TestHelpers.auth_headers({},
                                          manager)
  end

  path '/api/v1/chores' do
    # CREATE
    post 'Create a chore' do
      tags 'Chores'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :chore_data, in: :body, schema: {
        type: :object,
        properties: {
          chore: {
            type: :object,
            properties: {
              name: { type: :string, default: 'Chore name' },
              description: { type: :string, default: 'Description' },
              team_id: { type: :integer, default: 12 },
              executor_id: { type: :integer, default: 3 }
            },
            required: %w[name description executor_id team_id]
          }
        }
      }

      response '201', 'correct request' do
        let(:chore_data) do
          { chore: attributes_for(:chore,
                                  executor_id: executor.id,
                                  team_id: team.id) }
        end
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        schema type: :object,
               properties: {
                 chore: { type: :object,
                          properties: {
                            id: { type: :integer },
                            name: { type: :string },
                            description: { type: :string },
                            created_at: { type: :datetime },
                            updated_at: { type: :datetime },
                            manager: { type: :object,
                                       properties: {
                                         id: { type: :integer },
                                         email: { type: :string }
                                       } },
                            executor: { type: :object,
                                        properties: {
                                          id: { type: :integer },
                                          email: { type: :string }
                                        } },
                            team: { type: :object,
                                    properties: {
                                      id: { type: :integer },
                                      name: { type: :string }
                                    } }
                          } }
               }
        example 'application/json', :chore, {
          "id": 2,
          "name": 'Chorify',
          "description": 'Some amazing chore',
          "created_at": '2023-11-09T17:43:13.791Z',
          "updated_at": '2023-11-09T17:43:13.791Z',
          "manager": {
            "id": 32,
            "email": 'email@example.com'
          },
          "executor": {
            "id": 3,
            "email": 'corrie.stoltenberg@marquardt.example'
          },
          "team": {
            "id": 12,
            "name": 'Team name'
          }
        }

        it 'creates new chore for valid parameters' do
          expect do
            post api_v1_chores_path,
                 params: chore_data,
                 headers: auth_headers
          end.to change { Chore.count }.from(1).to(2)
        end

        run_test!
      end

      response '422', 'invalid request' do
        let(:chore_data) do
          { chore: attributes_for(:chore,
                                  name: '',
                                  executor_id: executor.id,
                                  team_id: team.id) }
        end
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
                                } },
                 executor_id: { type: :array,
                                properties: {
                                  type: :string
                                } },
                 team_id: { type: :array,
                            properties: {
                              type: :string
                            } }
               }

        example 'application/json', :chore,
                {
                  "name": [
                    "can't be blank",
                    'is too short (minimum is 2 characters)'
                  ],
                  "description": [
                    'is too short (minimum is 3 characters)'
                  ]
                }

        it "doesn't create a new chore for invalid parameters" do
          expect do
            post api_v1_chores_path,
                 params: chore_data,
                 headers: auth_headers
          end.not_to(change { Chore.count })
        end

        run_test!
      end

      response '403', 'unauthorized request' do
        let(:chore_data) do
          { chore: attributes_for(:chore,
                                  executor_id: executor.id,
                                  team_id: other_team.id) }
        end
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end

        it "doesn't create a new chore for a team not belonging to manager" do
          expect do
            post api_v1_chores_path,
                 params: chore_data,
                 headers: auth_headers
          end.not_to(change { Chore.count })
        end

        it "doesn't create a new chore for an executor from other team" do
          incorrect_chore_data = { chore: attributes_for(:chore,
                                                         team_id: team.id,
                                                         executor_id:
                                                         other_executor.id) }

          expect do
            post api_v1_chores_path,
                 params: incorrect_chore_data,
                 headers: auth_headers
          end.not_to(change { Chore.count })
        end

        run_test!
      end
    end

    # INDEX
    get 'Return a list of chores' do
      let!(:chore) do
        create(:chore,
               executor_id: executor.id,
               team_id: team.id,
               manager_id: manager.id)
      end
      let!(:second_chore) do
        create(:chore,
               executor_id: executor.id,
               team_id: other_team.id,
               manager_id: manager.id)
      end
      let!(:other_chore) do
        create(:chore,
               executor_id: other_executor.id,
               team_id: other_team.id,
               manager_id: other_manager.id)
      end
      tags 'Chores'
      security [bearer_auth: []]
      produces 'application/json'

      parameter name: :team_ids, in: :query, type: :array,
                items: { type: :integer }, required: false

      response '200', 'correct request' do
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end

        let(:team_ids) { [team.id] }
        schema  type: :array,
                properties: [
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string },
                    description: { type: :string },
                    manager_id: { type: :integer },
                    executor_id: { type: :integer },
                    team_id: { type: :integer },
                    created_at: { type: :datetime },
                    updated_at: { type: :datetime }
                  }
                ]

        example 'application/json', :chores, [
          {
            "id": 2,
            "name": 'Chorify',
            "description": 'Some amazing chore',
            "manager_id": 32,
            "executor_id": 3,
            "team_id": 12,
            "created_at": '2023-11-09T17:43:13.791Z',
            "updated_at": '2023-11-09T17:43:13.791Z'
          }
        ]

        it 'returns a list of chores for a user' do
          get api_v1_chores_path,
              headers: auth_headers
          expect(response.body).to eq([chore, second_chore].to_json)
        end

        it 'returns a list of chores for a user' do
          get api_v1_chores_path,
              params: { team_ids: [team.id] },
              headers: auth_headers
          expect(response.body).to eq([chore].to_json)
        end

        run_test!
      end
    end
  end

  path '/api/v1/chores/{id}' do
    let!(:chore) do
      create(:chore,
             executor_id: executor.id,
             team_id: team.id,
             manager_id: manager.id)
    end
    let!(:second_chore) do
      create(:chore,
             executor_id: executor.id,
             team_id: other_team.id,
             manager_id: manager.id)
    end
    let!(:other_chore) do
      create(:chore,
             executor_id: other_executor.id,
             team_id: other_team.id,
             manager_id: other_manager.id)
    end

    # SHOW
    get 'Return a chore' do
      tags 'Chores'
      security [bearer_auth: []]
      produces 'application/json'
      parameter name: :id, in: :path, schema: { type: :integer, default: 12 }

      response '200', 'correct request' do
        let(:id) { chore.id }
        schema type: :object,
               properties: {
                 chore: { type: :object,
                          properties: {
                            id: { type: :integer },
                            name: { type: :string },
                            description: { type: :string },
                            created_at: { type: :datetime },
                            updated_at: { type: :datetime },
                            manager: { type: :object,
                                       properties: {
                                         id: { type: :integer },
                                         email: { type: :string }
                                       } },
                            executor: { type: :object,
                                        properties: {
                                          id: { type: :integer },
                                          email: { type: :string }
                                        } },
                            team: { type: :object,
                                    properties: {
                                      id: { type: :integer },
                                      name: { type: :string }
                                    } }
                          } }
               }
        example 'application/json', :chore, {
          "id": 2,
          "name": 'Chorify',
          "description": 'Some amazing chore',
          "created_at": '2023-11-09T17:43:13.791Z',
          "updated_at": '2023-11-09T17:43:13.791Z',
          "manager": {
            "id": 32,
            "email": 'email@example.com'
          },
          "executor": {
            "id": 3,
            "email": 'corrie.stoltenberg@marquardt.example'
          },
          "team": {
            "id": 12,
            "name": 'Team name'
          }
        }

        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end

        it 'returns a chore for a correct user' do
          get api_v1_chore_path(chore.id),
              headers: auth_headers

          chore_presenter = ::ChorePresenter.new(chore)
          expect(response.body).to eq(chore_presenter.call.to_json)
        end

        run_test!
      end

      response '401', 'unauthorized request' do
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        let(:id) { other_chore.id }

        it "doesn't return a chore for an incorrect user" do
          get api_v1_chore_path(other_chore.id),
              headers: auth_headers

          expect(response.body).to eq(' ')
        end
        run_test!
      end
    end

    # UPDATE
    patch 'Update a chore' do
      tags 'Chores'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, schema: { type: :integer, default: 12 }
      parameter name: :chore_data, in: :body, schema: {
        type: :object,
        properties: {
          chore: {
            type: :object,
            properties: {
              name: { type: :string, default: 'Chore name' },
              description: { type: :string, default: 'Description' },
              manager_id: { type: :integer, default: 32 },
              executor_id: { type: :integer, default: 3 }
            },
            required: %w[name description executor_id manager_id]
          }
        }
      }

      response '200', 'correct request' do
        schema type: :object,
               properties: {
                 chore: { type: :object,
                          properties: {
                            id: { type: :integer },
                            name: { type: :string },
                            description: { type: :string },
                            created_at: { type: :datetime },
                            updated_at: { type: :datetime },
                            manager: { type: :object,
                                       properties: {
                                         id: { type: :integer },
                                         email: { type: :string }
                                       } },
                            executor: { type: :object,
                                        properties: {
                                          id: { type: :integer },
                                          email: { type: :string }
                                        } },
                            team: { type: :object,
                                    properties: {
                                      id: { type: :integer },
                                      name: { type: :string }
                                    } }
                          } }
               }
        example 'application/json', :chore, {
          "id": 2,
          "name": 'Chorify',
          "description": 'Some amazing chore',
          "created_at": '2023-11-09T17:43:13.791Z',
          "updated_at": '2023-11-09T17:43:13.791Z',
          "manager": {
            "id": 32,
            "email": 'email@example.com'
          },
          "executor": {
            "id": 3,
            "email": 'corrie.stoltenberg@marquardt.example'
          },
          "team": {
            "id": 12,
            "name": 'Team name'
          }
        }

        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        let(:id) { chore.id }
        let(:chore_data) do
          { chore: attributes_for(:chore,
                                  executor_id: executor.id,
                                  manager_id: manager.id) }
        end

        it 'returns a chore for a correct user' do
          patch api_v1_chore_path(chore.id),
                params: chore_data,
                headers: auth_headers

          chore.reload
          expect(response.body).to eq({
            id: chore.id,
            name: chore_data[:chore][:name],
            description: chore_data[:chore][:description],
            created_at: chore.created_at,
            updated_at: chore.updated_at,
            manager: {
              id: chore.manager.id,
              email: chore.manager.email
            },
            executor: {
              id: chore.executor.id,
              email: chore.executor.email
            },
            team: {
              id: chore.team.id,
              name: chore.team.name
            }
          }.to_json)
        end

        run_test!
      end

      response '403', 'forbidden request' do
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        let(:id) { other_chore.id }
        let(:chore_data) do
          { chore: attributes_for(:chore, manager_ids: [manager.id]) }
        end

        it 'returns a chore for a correct user' do
          patch api_v1_chore_path(other_chore.id),
                params: chore_data,
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
                 name: { type: :array,
                         properties: {
                           type: :string
                         } },
                 description: { type: :array,
                                properties: {
                                  type: :string
                                } },
                 executor_id: { type: :array,
                                properties: {
                                  type: :string
                                } },
                 manager_id: { type: :array,
                               properties: {
                                 type: :string
                               } }
               }

        example 'application/json', :chore,
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
        let(:id) { chore.id }
        let(:chore_data) do
          { chore: attributes_for(:chore, name: '',
                                          manager_id: manager.id,
                                          executor_id: executor.id) }
        end

        it 'returns a chore for a correct user' do
          patch api_v1_chore_path(chore.id),
                params: chore_data,
                headers: auth_headers

          expect(response.body).to eq(
            "{\"name\":[\"can't be blank\",\"is too short (minimum is 2 characters)\"]}"
          )
        end

        run_test!
      end
    end

    # DESTROY
    delete 'Delete a chore' do
      tags 'Chores'
      security [bearer_auth: []]
      parameter name: :id, in: :path,
                schema: { type: :integer, default: 12 }

      response '204', 'chore belonging to manager' do
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        let(:id) { chore.id }

        it 'deletes a chore for a correct user' do
          expect do
            delete api_v1_chore_path(second_chore.id),
                   headers: auth_headers
          end.to change { Chore.count }.from(2).to(1)
        end

        run_test!
      end

      response '403', 'chore not belonging to manager' do
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end
        let(:id) { other_chore.id }

        it "doesn't delete a chore for an incorrect user" do
          expect do
            delete api_v1_chore_path(other_chore.id),
                   headers: auth_headers
          end.not_to(change { Chore.count })
        end

        run_test!
      end
    end
  end
end
