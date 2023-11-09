# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, type: :model do
  let!(:manager) { create(:user, role: 1) }
  let(:team_attrs) { attributes_for(:team) }
  let(:team) do
    team = Team.new(team_attrs)
    team.managers << manager
    team
  end

  it 'is valid for correct attributes' do
    expect(team).to be_valid
  end

  context 'name' do
    it 'must be present' do
      team.name = nil
      expect(team).not_to be_valid
    end

    it 'must be longer than 2 characters' do
      team.name = 'a'
      expect(team).not_to be_valid
    end

    it 'must be shorter than 24 characters' do
      team.name = 'a' * 25
      expect(team).not_to be_valid
    end
  end

  context 'description' do
    it 'must be present' do
      team.description = nil
      expect(team).not_to be_valid
    end

    it 'must be longer than 3 characters' do
      team.description = 'aa'
      expect(team).not_to be_valid
    end

    context 'managers' do
      it 'cannot be empty' do
        team.managers = []
        expect(team).not_to be_valid
      end
    end
  end
end
