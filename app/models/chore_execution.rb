# frozen_string_literal: true

# model for chore execution
class ChoreExecution < ApplicationRecord
  belongs_to :chore
  delegate :manager, to: :chore
  delegate :executor, to: :chore
  delegate :team, to: :chore
end
