class CreateChoreExecutions < ActiveRecord::Migration[7.0]
  def change
    create_table :chore_executions do |t|
      t.datetime :date
      t.references :chore, null: false, foreign_key: true

      t.timestamps
    end
  end
end
