class UsersManageAndExecuteTeams < ActiveRecord::Migration[7.0]
  def change
    # Create the table
    create_join_table(:users, :teams, table_name: "user_team_managed")
    # If the table gets large we'll need indices on id
    add_index "user_team_managed", ["user_id"]
    add_index "user_team_managed", ["team_id"]
    # Enforce FK relationships
    add_foreign_key "user_team_managed", "users"
    add_foreign_key "user_team_managed", "teams"
    # No null entries
    change_column_null(:user_team_managed, :user_id, false)
    change_column_null(:user_team_managed, :team_id, false)
    # Prevent duplicate entries
    add_index "user_team_managed", ["user_id", "team_id"], unique: true

    create_join_table(:users, :teams, table_name: "user_team_executed")
    add_index "user_team_executed", ["user_id"]
    add_index "user_team_executed", ["team_id"]
    add_foreign_key "user_team_executed", "users"
    add_foreign_key "user_team_executed", "teams"
    change_column_null(:user_team_executed, :user_id, false)
    change_column_null(:user_team_executed, :team_id, false)
    add_index "user_team_executed", ["user_id", "team_id"], unique: true
  end
end
