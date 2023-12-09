# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChoreExecution, type: :model do
  let!(:executor) { create(:user, role: 0) }
  let!(:manager) { create(:user, role: 1) }
  let!(:team) do
    create(:team, manager_ids: [manager.id], executor_ids: [executor.id])
  end
  let!(:chore) do
    create(:chore,
           executor_id: executor.id,
           team_id: team.id,
           manager_id: manager.id)
  end
  let!(:chore_execution) do
    create(:chore_execution, chore:)
  end

  it "delegates team to it's chore" do
    expect(chore_execution.team).to eq(chore.team)
  end

  it "delegates executor to it's chore" do
    expect(chore_execution.executor).to eq(chore.executor)
  end

  it "delegates manager to it's chore" do
    expect(chore_execution.manager).to eq(chore.manager)
  end
end
