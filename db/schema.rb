# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_11_23_123033) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chore_executions", force: :cascade do |t|
    t.datetime "date"
    t.bigint "chore_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chore_id"], name: "index_chore_executions_on_chore_id"
  end

  create_table "chores", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.bigint "manager_id", null: false
    t.bigint "executor_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["executor_id"], name: "index_chores_on_executor_id"
    t.index ["manager_id"], name: "index_chores_on_manager_id"
    t.index ["team_id"], name: "index_chores_on_team_id"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_team_executed", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.index ["team_id"], name: "index_user_team_executed_on_team_id"
    t.index ["user_id", "team_id"], name: "index_user_team_executed_on_user_id_and_team_id", unique: true
    t.index ["user_id"], name: "index_user_team_executed_on_user_id"
  end

  create_table "user_team_managed", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.index ["team_id"], name: "index_user_team_managed_on_team_id"
    t.index ["user_id", "team_id"], name: "index_user_team_managed_on_user_id_and_team_id", unique: true
    t.index ["user_id"], name: "index_user_team_managed_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chore_executions", "chores"
  add_foreign_key "chores", "teams"
  add_foreign_key "chores", "users", column: "executor_id"
  add_foreign_key "chores", "users", column: "manager_id"
  add_foreign_key "user_team_executed", "teams"
  add_foreign_key "user_team_executed", "users"
  add_foreign_key "user_team_managed", "teams"
  add_foreign_key "user_team_managed", "users"
end
