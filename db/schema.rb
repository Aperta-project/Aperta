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

ActiveRecord::Schema.define(version: 20141028142236) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "affiliations", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  add_index "affiliations", ["user_id"], name: "index_affiliations_on_user_id", using: :btree

  create_table "api_keys", force: true do |t|
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "author_paper", force: true do |t|
  end

  create_table "authors", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "paper_id"
    t.integer  "actable_id"
    t.string   "actable_type"
  end

  create_table "comment_looks", force: true do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comment_looks", ["comment_id"], name: "index_comment_looks_on_comment_id", using: :btree
  add_index "comment_looks", ["user_id"], name: "index_comment_looks_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "commenter_id"
    t.integer  "task_id"
  end

  add_index "comments", ["commenter_id", "task_id"], name: "index_comments_on_commenter_id_and_task_id", using: :btree
  add_index "comments", ["commenter_id"], name: "index_comments_on_commenter_id", using: :btree
  add_index "comments", ["task_id"], name: "index_comments_on_task_id", using: :btree

  create_table "credentials", force: true do |t|
    t.string  "provider"
    t.string  "uid"
    t.integer "user_id"
  end

  add_index "credentials", ["uid", "provider"], name: "index_credentials_on_uid_and_provider", using: :btree

  create_table "figures", force: true do |t|
    t.string   "attachment"
    t.integer  "paper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "caption"
    t.string   "status",     default: "processing"
  end

  add_index "figures", ["paper_id"], name: "index_figures_on_paper_id", using: :btree

  create_table "flows", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "empty_text"
    t.integer  "user_id"
  end

  create_table "ihat_jobs", force: true do |t|
    t.integer  "paper_id"
    t.string   "job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ihat_jobs", ["paper_id"], name: "index_ihat_jobs_on_paper_id", using: :btree

  create_table "journal_task_types", force: true do |t|
    t.integer "task_type_id"
    t.integer "journal_id"
    t.string  "title"
    t.string  "role"
    t.string  "kind"
  end

  add_index "journal_task_types", ["journal_id"], name: "index_journal_task_types_on_journal_id", using: :btree
  add_index "journal_task_types", ["task_type_id"], name: "index_journal_task_types_on_task_type_id", using: :btree

  create_table "journals", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.string   "epub_cover"
    t.text     "epub_css"
    t.text     "pdf_css"
    t.text     "manuscript_css"
    t.text     "description"
  end

  create_table "manuscript_manager_templates", force: true do |t|
    t.string  "paper_type"
    t.integer "journal_id"
  end

  add_index "manuscript_manager_templates", ["journal_id"], name: "index_manuscript_manager_templates_on_journal_id", using: :btree

  create_table "manuscripts", force: true do |t|
    t.string   "source"
    t.integer  "paper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     default: "processing"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

  add_index "paper_roles", ["paper_id"], name: "index_paper_roles_on_paper_id", using: :btree
  add_index "paper_roles", ["role"], name: "index_paper_roles_on_role", using: :btree
  add_index "paper_roles", ["user_id", "paper_id"], name: "index_paper_roles_on_user_id_and_paper_id", using: :btree
  add_index "paper_roles", ["user_id"], name: "index_paper_roles_on_user_id", using: :btree

  create_table "papers", force: true do |t|
    t.string   "short_title"
    t.string   "title"
    t.text     "body",              default: ""
    t.text     "abstract",          default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "paper_type"
    t.boolean  "submitted",         default: false, null: false
    t.integer  "journal_id",                        null: false
    t.string   "decision"
    t.text     "decision_letter"
    t.datetime "published_at"
    t.integer  "locked_by_id"
    t.datetime "last_heartbeat_at"
    t.integer  "striking_image_id"
    t.boolean  "editable",          default: true
  end

  add_index "papers", ["journal_id"], name: "index_papers_on_journal_id", using: :btree
  add_index "papers", ["user_id"], name: "index_papers_on_user_id", using: :btree

  create_table "participations", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "task_id"
    t.integer  "participant_id"
  end

  add_index "participations", ["participant_id"], name: "index_participations_on_participant_id", using: :btree
  add_index "participations", ["task_id"], name: "index_participations_on_task_id", using: :btree

  create_table "phase_templates", force: true do |t|
    t.string   "name"
    t.integer  "manuscript_manager_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "phase_templates", ["manuscript_manager_template_id"], name: "index_phase_templates_on_manuscript_manager_template_id", using: :btree

  create_table "phases", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "paper_id",   null: false
  end

  add_index "phases", ["paper_id"], name: "index_phases_on_paper_id", using: :btree

  create_table "plos_authors_plos_authors", force: true do |t|
    t.integer  "plos_authors_task_id"
    t.string   "middle_initial"
    t.string   "email"
    t.string   "department"
    t.string   "title"
    t.boolean  "corresponding",         default: false, null: false
    t.boolean  "deceased",              default: false, null: false
    t.string   "affiliation"
    t.string   "secondary_affiliation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_attachments", force: true do |t|
    t.integer  "question_id"
    t.string   "attachment"
    t.string   "title"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_attachments", ["question_id"], name: "index_question_attachments_on_question_id", using: :btree

  create_table "questions", force: true do |t|
    t.text    "question"
    t.text    "answer"
    t.string  "ident"
    t.integer "task_id"
    t.json    "additional_data"
  end

  add_index "questions", ["task_id"], name: "index_questions_on_task_id", using: :btree

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

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "journal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "can_administer_journal",                default: false,    null: false
    t.boolean  "can_view_assigned_manuscript_managers", default: false,    null: false
    t.boolean  "can_view_all_manuscript_managers",      default: false,    null: false
    t.string   "kind",                                  default: "custom", null: false
  end

  add_index "roles", ["kind"], name: "index_roles_on_kind", using: :btree

  create_table "standard_tasks_funded_authors", force: true do |t|
    t.integer "author_id"
    t.integer "funder_id"
  end

  add_index "standard_tasks_funded_authors", ["author_id", "funder_id"], name: "funded_authors_unique_index", unique: true, using: :btree
  add_index "standard_tasks_funded_authors", ["author_id"], name: "index_standard_tasks_funded_authors_on_author_id", using: :btree
  add_index "standard_tasks_funded_authors", ["funder_id"], name: "index_standard_tasks_funded_authors_on_funder_id", using: :btree

  create_table "standard_tasks_funders", force: true do |t|
    t.string   "name"
    t.string   "grant_number"
    t.string   "website"
    t.boolean  "funder_had_influence"
    t.text     "funder_influence_description"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "standard_tasks_funders", ["task_id"], name: "index_standard_tasks_funders_on_task_id", using: :btree

  create_table "supporting_information_files", force: true do |t|
    t.integer  "paper_id"
    t.string   "title"
    t.string   "caption"
    t.string   "attachment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     default: "processing"
  end

  add_index "supporting_information_files", ["paper_id"], name: "index_supporting_information_files_on_paper_id", using: :btree

  create_table "task_templates", force: true do |t|
    t.integer "journal_task_type_id"
    t.integer "phase_template_id"
    t.json    "template",             default: [], null: false
    t.string  "title"
  end

  add_index "task_templates", ["journal_task_type_id"], name: "index_task_templates_on_journal_task_type_id", using: :btree
  add_index "task_templates", ["phase_template_id"], name: "index_task_templates_on_phase_template_id", using: :btree

  create_table "tasks", force: true do |t|
    t.string   "title",                       null: false
    t.string   "type",       default: "Task"
    t.integer  "phase_id",                    null: false
    t.boolean  "completed",  default: false,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                        null: false
    t.json     "body",       default: [],     null: false
  end

  add_index "tasks", ["id", "type"], name: "index_tasks_on_id_and_type", using: :btree
  add_index "tasks", ["phase_id"], name: "index_tasks_on_phase_id", using: :btree

  create_table "user_roles", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
  end

  add_index "user_roles", ["role_id"], name: "index_user_roles_on_role_id", using: :btree
  add_index "user_roles", ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", using: :btree
  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name",             default: "",    null: false
    t.string   "last_name",              default: "",    null: false
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
    t.boolean  "site_admin",             default: false, null: false
    t.string   "avatar"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
