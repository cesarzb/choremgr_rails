# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'
require 'devise/jwt/test_helpers'

describe 'Chore executions' do
  let!(:manager) { create(:user, role: 1) }
  let!(:second_manager) { create(:user, role: 1) }
  let!(:executor) { create(:user, role: 0) }
  let!(:other_executor) { create(:user, role: 0) }
  let!(:team)     do
    create(:team, manager_ids: [manager.id, second_manager.id],
                  executor_ids: [executor.id])
  end
  let!(:chore) do
    create(:chore, manager_id: manager.id, executor_id: executor.id,
                   team_id: team.id)
  end

  let(:executor_auth_headers) do
    Devise::JWT::TestHelpers.auth_headers({},
                                          executor)
  end

  let(:manager_auth_headers) do
    Devise::JWT::TestHelpers.auth_headers({},
                                          manager)
  end

  let(:other_executor_auth_headers) do
    Devise::JWT::TestHelpers.auth_headers({},
                                          other_executor)
  end

  path '/api/v1/teams/{team_id}/chores/{chore_id}/chore_executions' do
    # CREATE
    post 'Create a chore execution' do
      tags 'Chore executions'
      security [bearer_auth: []]
      produces 'application/json'
      parameter name: :team_id, in: :path,
                schema: { type: :integer, default: 12 }
      parameter name: :chore_id, in: :path,
                schema: { type: :integer, default: 12 }

      response '201',
               'correct request' do
        let(:team_id) { team.id }
        let(:chore_id) { chore.id }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                executor)['Authorization']
        end
        schema type: :object,
               properties: {}
        example 'application/json', :chore, {}

        run_test!
        it 'works for chore executor' do
          expect do
            post api_v1_team_chore_chore_executions_path(team_id, chore_id),
                 headers: executor_auth_headers
          end.to change { ChoreExecution.count }.from(1).to(2)
        end
      end

      response '422',
               'invalid request' do
        let(:team_id) { team.id }
        let(:chore_id) { chore.id + 1 }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                executor)['Authorization']
        end
        schema type: :object,
               properties: {}

        example 'application/json', :chore,
                {}

        run_test!
        it 'fails for not existing chore' do
          expect do
            post api_v1_team_chore_chore_executions_path(team_id, chore_id),
                 headers: executor_auth_headers
          end.not_to(change { ChoreExecution.count })
          expect(response.body).to eq(
            "{\"error\":\"Chore doesn't exist!\"}"
          )
        end
      end

      response '403',
               'unauthorized request' do
        let(:team_id) { team.id }
        let(:chore_id) { chore.id }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                manager)['Authorization']
        end

        run_test!
        it 'fails for manager' do
          expect do
            post api_v1_team_chore_chore_executions_path(team_id, chore_id),
                 headers: manager_auth_headers
          end.not_to(change { ChoreExecution.count })
          expect(response.body).to eq(
            '{"error":"You are not the executor of this chore!"}'
          )
        end

        it 'fail for other executor' do
          expect do
            post api_v1_team_chore_chore_executions_path(team_id, chore_id),
                 headers: other_executor_auth_headers
          end.not_to(change { ChoreExecution.count })
          expect(response.body).to eq(
            '{"error":"You are not the executor of this chore!"}'
          )
        end
      end
    end

    # INDEX
    get 'Index chore executions for a given task' do
      tags 'Chore executions'
      security [bearer_auth: []]
      produces 'application/json'
      parameter name: :team_id, in: :path,
                schema: { type: :integer, default: 12 }
      parameter name: :chore_id, in: :path,
                schema: { type: :integer, default: 12 }

      let!(:chore_execution) do
        create(:chore_execution, chore:)
      end
      let!(:second_chore_execution) do
        create(:chore_execution, chore:)
      end

      response '200', 'executor or team manager request' do
        let(:team_id) { team.id }
        let(:chore_id) { chore.id }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                executor)['Authorization']
        end
        schema type: :array,
               properties: [
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   date: { type: :string },
                   chore_id: { type: :integer },
                   created_at: { type: :datetime },
                   updated_at: { type: :datetime }
                 }
               ]

        example 'application/json', :chore_executions, [
          { id: 594,
            date: '2023-11-23T13:30:33.000Z',
            chore_id: 999,
            created_at: '2023-11-30T13:36:33.469Z',
            updated_at: '2023-11-30T13:36:33.469Z' },
          { id: 595,
            date: '2023-11-23T13:30:33.000Z',
            chore_id: 999,
            created_at: '2023-11-30T13:36:33.471Z',
            updated_at: '2023-11-30T13:36:33.471Z' }
        ]

        run_test!
        it 'returns list of chore executions for chore executor' do
          get api_v1_team_chore_chore_executions_path(team_id, chore_id),
              headers: executor_auth_headers
          expect(response.body).to eq([second_chore_execution,
                                       chore_execution].to_json)
        end

        it 'returns list of chore executions for chore manager' do
          get api_v1_team_chore_chore_executions_path(team_id, chore_id),
              headers: manager_auth_headers
          expect(response.body).to eq([second_chore_execution,
                                       chore_execution].to_json)
        end
        it 'returns list of chore executions for team manager' do
          second_manager_auth_headers = Devise::JWT::TestHelpers
                                        .auth_headers({}, second_manager)
          get api_v1_team_chore_chore_executions_path(team_id, chore_id),
              headers: second_manager_auth_headers
          expect(response.body).to eq([second_chore_execution,
                                       chore_execution].to_json)
        end
      end

      response '422', 'from wrong user' do
        let(:team_id) { team.id }
        let(:chore_id) { chore.id + 2 }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                executor)['Authorization']
        end

        schema type: :object,
               properties: {
                 error: { type: :string }
               }

        example 'application/json', :chore_non_existent, {
          error: "Chore doesn't exist!"
        }

        run_test!
        it 'returns an error for non existent chore' do
          get api_v1_team_chore_chore_executions_path(team_id, chore_id),
              headers: executor_auth_headers
          expect(response.body).to eq({ error: "Chore doesn't exist!" }.to_json)
        end
      end

      response '403', 'executor or team manager request' do
        let(:team_id) { team.id }
        let(:chore_id) { chore.id }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                other_executor)['Authorization']
        end
        run_test!
        it 'returns an error for a different executor' do
          get api_v1_team_chore_chore_executions_path(team_id, chore_id),
              headers: other_executor_auth_headers
          expect(response.body).to eq(
            { error: 'You are not the executor of this chore!' }.to_json
          )
        end

        it 'returns an error for a manager not from the team' do
          other_manager = create(:user, role: 1)
          other_mgr_auth_headers = Devise::JWT::TestHelpers
                                   .auth_headers({},
                                                 other_manager)
          get api_v1_team_chore_chore_executions_path(team_id, chore_id),
              headers: other_mgr_auth_headers
          expect(response.body).to eq(
            { error: 'You are not the executor of this chore!' }.to_json
          )
        end
      end
    end
  end

  path '/api/v1/teams/{team_id}/chores/{chore_id}/chore_executions/{id}' do
    let!(:chore_execution) do
      create(:chore_execution, chore:)
    end
    let!(:second_chore_execution) do
      create(:chore_execution, chore:)
    end

    # DELETE
    delete 'Delete a chore execution' do
      tags 'Chore executions'
      security [bearer_auth: []]
      produces 'application/json'
      parameter name: :team_id, in: :path,
                schema: { type: :integer, default: 12 }
      parameter name: :chore_id, in: :path,
                schema: { type: :integer, default: 12 }
      parameter name: :id, in: :path,
                schema: { type: :integer, default: 12 }

      response '204', 'correct request' do
        let(:team_id) { team.id }
        let(:chore_id) { chore.id }
        let(:id) { chore_execution.id }
        let(:second_id) { second_chore_execution.id }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                executor)['Authorization']
        end

        run_test!
        it 'works for chore executor' do
          expect do
            delete api_v1_team_chore_chore_execution_path(team_id,
                                                          chore_id,
                                                          second_id),
                   headers: executor_auth_headers
          end.to change { ChoreExecution.count }.from(1).to(0)
        end
      end

      response '422', 'non existent chore' do
        let(:team_id) { team.id }
        let(:chore_id) { chore.id + 2 }
        let(:valid_chore_id) { chore.id }
        let(:id) { chore_execution.id }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                executor)['Authorization']
        end

        run_test!
        it "doesn't work for non existent chore" do
          expect do
            delete api_v1_team_chore_chore_execution_path(team_id,
                                                          chore_id,
                                                          id),
                   headers: executor_auth_headers
          end.not_to(change { ChoreExecution.count })
        end

        it "doesn't work for non existent chore execution" do
          expect do
            delete api_v1_team_chore_chore_execution_path(team_id,
                                                          valid_chore_id,
                                                          id + 42),
                   headers: executor_auth_headers
          end.not_to(change { ChoreExecution.count })
        end
      end

      response '403',
               'unauthorized request' do
        let(:team_id) { team.id }
        let(:chore_id) { chore.id }
        let(:id) { chore_execution.id }
        let(:Authorization) do
          Devise::JWT::TestHelpers.auth_headers({},
                                                other_executor)['Authorization']
        end

        run_test!
        it 'fails for manager' do
          expect do
            post api_v1_team_chore_chore_executions_path(team_id, chore_id, id),
                 headers: manager_auth_headers
          end.not_to(change { ChoreExecution.count })
          expect(response.body).to eq(
            '{"error":"You are not the executor of this chore!"}'
          )
        end

        it 'fail for other executor' do
          expect do
            post api_v1_team_chore_chore_executions_path(team_id, chore_id, id),
                 headers: other_executor_auth_headers
          end.not_to(change { ChoreExecution.count })
          expect(response.body).to eq(
            '{"error":"You are not the executor of this chore!"}'
          )
        end
      end
    end
  end
end
