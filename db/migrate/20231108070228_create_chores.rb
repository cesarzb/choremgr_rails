class CreateChores < ActiveRecord::Migration[7.0]
  def change
    create_table :chores do |t|
      t.string :name
      t.text :description
      t.references :manager, null: false, foreign_key: { to_table: :users }
      t.references :executor, null: false, foreign_key: { to_table: :users }
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
  end
end
