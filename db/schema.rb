# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140128001935) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "declarations", force: true do |t|
    t.text    "question", null: false
    t.text    "answer"
    t.integer "paper_id"
  end

  add_index "declarations", ["paper_id"], name: "index_declarations_on_paper_id", using: :btree

  create_table "figures", force: true do |t|
    t.string   "attachment"
    t.integer  "paper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "figures", ["paper_id"], name: "index_figures_on_paper_id", using: :btree

  create_table "journal_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "journal_id"
    t.boolean  "editor",     default: false, null: false
    t.boolean  "reviewer",   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "journal_roles", ["journal_id"], name: "index_journal_roles_on_journal_id", using: :btree
  add_index "journal_roles", ["user_id"], name: "index_journal_roles_on_user_id", using: :btree

  create_table "journals", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
  end

  create_table "paper_reviews", force: true do |t|
    t.integer  "task_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paper_reviews", ["task_id"], name: "index_paper_reviews_on_task_id", using: :btree

  create_table "paper_roles", force: true do |t|
    t.integer  "user_id"
    t.integer  "paper_id"
    t.boolean  "editor",     default: false, null: false
    t.boolean  "reviewer",   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paper_roles", ["paper_id"], name: "index_paper_roles_on_paper_id", using: :btree
  add_index "paper_roles", ["user_id"], name: "index_paper_roles_on_user_id", using: :btree

  create_table "papers", force: true do |t|
    t.string   "short_title"
    t.string   "title"
    t.text     "body",            default: ""
    t.text     "abstract",        default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "paper_type"
    t.text     "authors",         default: "--- []\n"
    t.boolean  "submitted",       default: false,      null: false
    t.integer  "journal_id",                           null: false
    t.string   "decision"
    t.text     "decision_letter"
  end

  add_index "papers", ["journal_id"], name: "index_papers_on_journal_id", using: :btree
  add_index "papers", ["user_id"], name: "index_papers_on_user_id", using: :btree

  create_table "phases", force: true do |t|
    t.integer  "task_manager_id", null: false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "phases", ["task_manager_id"], name: "index_phases_on_task_manager_id", using: :btree

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "task_managers", force: true do |t|
    t.integer  "paper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "task_managers", ["paper_id"], name: "index_task_managers_on_paper_id", using: :btree

  create_table "tasks", force: true do |t|
    t.string   "title",                       null: false
    t.string   "type"
    t.integer  "assignee_id"
    t.integer  "phase_id",                    null: false
    t.boolean  "completed",   default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                        null: false
    t.text     "body"
  end

  add_index "tasks", ["assignee_id"], name: "index_tasks_on_assignee_id", using: :btree
  add_index "tasks", ["phase_id"], name: "index_tasks_on_phase_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name",             default: "",    null: false
    t.string   "last_name",              default: "",    null: false
    t.string   "affiliation",            default: "",    null: false
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.boolean  "admin",                  default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
