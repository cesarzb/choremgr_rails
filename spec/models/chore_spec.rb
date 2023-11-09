# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Chore, type: :model do
  let!(:manager) { create(:user, role: 1) }
  let!(:executor) { create(:user, role: 0) }
  let!(:team) do
    create(:team, manager_ids: [manager.id], executor_ids: [executor.id])
  end
  let(:chore_attrs) do
    attributes_for(:chore, team_id: team.id,
                           executor_id: executor.id)
  end

  let(:chore) do
    chore = Chore.new(chore_attrs)
    chore.manager = manager
    chore
  end

  it 'is valid for correct attributes' do
    expect(chore).to be_valid
  end

  context 'name' do
    it 'must be present' do
      chore.name = nil
      expect(chore).not_to be_valid
    end

    it 'must be longer than 2 characters' do
      chore.name = 'a'
      expect(chore).not_to be_valid
    end

    it 'must be shorter than 24 characters' do
      chore.name = 'a' * 25
      expect(chore).not_to be_valid
    end
  end

  context 'description' do
    it 'must be present' do
      chore.description = nil
      expect(chore).not_to be_valid
    end

    it 'must be longer than 3 characters' do
      chore.description = 'aa'
      expect(chore).not_to be_valid
    end

    context 'manager' do
      it 'must be present' do
        chore.manager = nil
        expect(chore).not_to be_valid
      end
    end

    context 'executor' do
      it 'must be present' do
        chore.executor = nil
        expect(chore).not_to be_valid
      end
    end
    context 'team' do
      it 'must be present' do
        chore.team = nil
        expect(chore).not_to be_valid
      end
    end
  end
end
