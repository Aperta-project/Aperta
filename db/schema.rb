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

ActiveRecord::Schema.define(version: 20150210200733) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "affiliations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",       limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",      limit: 255
  end

  add_index "affiliations", ["user_id"], name: "index_affiliations_on_user_id", using: :btree

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "file",            limit: 255
    t.integer  "attachable_id"
    t.string   "attachable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",           limit: 255
    t.string   "caption",         limit: 255
    t.string   "status",          limit: 255, default: "processing"
  end

  create_table "authors", force: :cascade do |t|
    t.string   "first_name",   limit: 255
    t.string   "last_name",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "paper_id"
    t.integer  "actable_id"
    t.string   "actable_type", limit: 255
  end

  create_table "comment_looks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comment_looks", ["comment_id"], name: "index_comment_looks_on_comment_id", using: :btree
  add_index "comment_looks", ["user_id"], name: "index_comment_looks_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "commenter_id"
    t.integer  "task_id"
    t.json     "entities"
  end

  add_index "comments", ["commenter_id", "task_id"], name: "index_comments_on_commenter_id_and_task_id", using: :btree
  add_index "comments", ["commenter_id"], name: "index_comments_on_commenter_id", using: :btree
  add_index "comments", ["task_id"], name: "index_comments_on_task_id", using: :btree

  create_table "credentials", force: :cascade do |t|
    t.string  "provider", limit: 255
    t.string  "uid",      limit: 255
    t.integer "user_id"
  end

  add_index "credentials", ["uid", "provider"], name: "index_credentials_on_uid_and_provider", using: :btree

  create_table "figures", force: :cascade do |t|
    t.string   "attachment", limit: 255
    t.integer  "paper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",      limit: 255
    t.string   "caption",    limit: 255
    t.string   "status",     limit: 255, default: "processing"
  end

  add_index "figures", ["paper_id"], name: "index_figures_on_paper_id", using: :btree

  create_table "flows", force: :cascade do |t|
    t.string  "title",    limit: 255
    t.integer "role_id"
    t.integer "position"
    t.text    "query"
  end

  create_table "invitations", force: :cascade do |t|
    t.string   "email"
    t.string   "code"
    t.integer  "task_id"
    t.integer  "invitee_id"
    t.integer  "actor_id"
    t.string   "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "invitations", ["actor_id"], name: "index_invitations_on_actor_id", using: :btree
  add_index "invitations", ["code"], name: "index_invitations_on_code", unique: true, using: :btree
  add_index "invitations", ["email"], name: "index_invitations_on_email", using: :btree
  add_index "invitations", ["invitee_id"], name: "index_invitations_on_invitee_id", using: :btree
  add_index "invitations", ["task_id"], name: "index_invitations_on_task_id", using: :btree

  create_table "journal_task_types", force: :cascade do |t|
    t.integer "task_type_id"
    t.integer "journal_id"
    t.string  "title",        limit: 255
    t.string  "role",         limit: 255
    t.string  "kind",         limit: 255
  end

  add_index "journal_task_types", ["journal_id"], name: "index_journal_task_types_on_journal_id", using: :btree
  add_index "journal_task_types", ["task_type_id"], name: "index_journal_task_types_on_task_type_id", using: :btree

  create_table "journals", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo",                 limit: 255
    t.string   "epub_cover",           limit: 255
    t.text     "epub_css"
    t.text     "pdf_css"
    t.text     "manuscript_css"
    t.text     "description"
    t.string   "doi_publisher_prefix", limit: 255
    t.string   "doi_journal_prefix",   limit: 255
    t.string   "last_doi_issued",      limit: 255, default: "0"
  end

  create_table "manuscript_manager_templates", force: :cascade do |t|
    t.string  "paper_type", limit: 255
    t.integer "journal_id"
  end

  add_index "manuscript_manager_templates", ["journal_id"], name: "index_manuscript_manager_templates_on_journal_id", using: :btree

  create_table "manuscripts", force: :cascade do |t|
    t.string   "source",     limit: 255
    t.integer  "paper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     limit: 255, default: "processing"
  end

  create_table "paper_reviews", force: :cascade do |t|
    t.integer  "task_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paper_reviews", ["task_id"], name: "index_paper_reviews_on_task_id", using: :btree

  create_table "paper_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "paper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",       limit: 255
  end

  add_index "paper_roles", ["paper_id"], name: "index_paper_roles_on_paper_id", using: :btree
  add_index "paper_roles", ["role"], name: "index_paper_roles_on_role", using: :btree
  add_index "paper_roles", ["user_id", "paper_id"], name: "index_paper_roles_on_user_id_and_paper_id", using: :btree
  add_index "paper_roles", ["user_id"], name: "index_paper_roles_on_user_id", using: :btree

  create_table "papers", force: :cascade do |t|
    t.string   "short_title",       limit: 255
    t.string   "title",             limit: 255
    t.text     "body",                          default: ""
    t.text     "abstract",                      default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "paper_type",        limit: 255
    t.boolean  "submitted",                     default: false, null: false
    t.integer  "journal_id",                                    null: false
    t.string   "decision",          limit: 255
    t.text     "decision_letter"
    t.datetime "published_at"
    t.integer  "locked_by_id"
    t.datetime "last_heartbeat_at"
    t.integer  "striking_image_id"
    t.boolean  "editable",                      default: true
    t.text     "doi"
  end

  add_index "papers", ["doi"], name: "index_papers_on_doi", unique: true, using: :btree
  add_index "papers", ["journal_id"], name: "index_papers_on_journal_id", using: :btree
  add_index "papers", ["user_id"], name: "index_papers_on_user_id", using: :btree

  create_table "participations", force: :cascade do |t|
    t.integer  "task_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "participations", ["task_id"], name: "index_participations_on_task_id", using: :btree
  add_index "participations", ["user_id"], name: "index_participations_on_user_id", using: :btree

  create_table "phase_templates", force: :cascade do |t|
    t.string   "name",                           limit: 255
    t.integer  "manuscript_manager_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "phase_templates", ["manuscript_manager_template_id"], name: "index_phase_templates_on_manuscript_manager_template_id", using: :btree

  create_table "phases", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "paper_id",               null: false
  end

  add_index "phases", ["paper_id"], name: "index_phases_on_paper_id", using: :btree

  create_table "plos_authors_plos_authors", force: :cascade do |t|
    t.integer  "plos_authors_task_id"
    t.string   "middle_initial",        limit: 255
    t.string   "email",                 limit: 255
    t.string   "department",            limit: 255
    t.string   "title",                 limit: 255
    t.boolean  "corresponding",                     default: false, null: false
    t.boolean  "deceased",                          default: false, null: false
    t.string   "affiliation",           limit: 255
    t.string   "secondary_affiliation", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "question_attachments", force: :cascade do |t|
    t.integer  "question_id"
    t.string   "attachment",  limit: 255
    t.string   "title",       limit: 255
    t.string   "status",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_attachments", ["question_id"], name: "index_question_attachments_on_question_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.text    "question"
    t.text    "answer"
    t.string  "ident",           limit: 255
    t.integer "task_id"
    t.json    "additional_data"
  end

  add_index "questions", ["task_id"], name: "index_questions_on_task_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",                                  limit: 255
    t.integer  "journal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "can_administer_journal",                            default: false,    null: false
    t.boolean  "can_view_assigned_manuscript_managers",             default: false,    null: false
    t.boolean  "can_view_all_manuscript_managers",                  default: false,    null: false
    t.string   "kind",                                  limit: 255, default: "custom", null: false
    t.boolean  "can_view_flow_manager",                             default: false,    null: false
  end

  add_index "roles", ["kind"], name: "index_roles_on_kind", using: :btree

  create_table "standard_tasks_funded_authors", force: :cascade do |t|
    t.integer "author_id"
    t.integer "funder_id"
  end

  add_index "standard_tasks_funded_authors", ["author_id", "funder_id"], name: "funded_authors_unique_index", unique: true, using: :btree
  add_index "standard_tasks_funded_authors", ["author_id"], name: "index_standard_tasks_funded_authors_on_author_id", using: :btree
  add_index "standard_tasks_funded_authors", ["funder_id"], name: "index_standard_tasks_funded_authors_on_funder_id", using: :btree

  create_table "standard_tasks_funders", force: :cascade do |t|
    t.string   "name",                         limit: 255
    t.string   "grant_number",                 limit: 255
    t.string   "website",                      limit: 255
    t.boolean  "funder_had_influence"
    t.text     "funder_influence_description"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "standard_tasks_funders", ["task_id"], name: "index_standard_tasks_funders_on_task_id", using: :btree

  create_table "supporting_information_files", force: :cascade do |t|
    t.integer  "paper_id"
    t.string   "title",      limit: 255
    t.string   "caption",    limit: 255
    t.string   "attachment", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     limit: 255, default: "processing"
  end

  add_index "supporting_information_files", ["paper_id"], name: "index_supporting_information_files_on_paper_id", using: :btree

  create_table "task_templates", force: :cascade do |t|
    t.integer "journal_task_type_id"
    t.integer "phase_template_id"
    t.json    "template",                         default: [], null: false
    t.string  "title",                limit: 255
  end

  add_index "task_templates", ["journal_task_type_id"], name: "index_task_templates_on_journal_task_type_id", using: :btree
  add_index "task_templates", ["phase_template_id"], name: "index_task_templates_on_phase_template_id", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "title",      limit: 255,                  null: false
    t.string   "type",       limit: 255, default: "Task"
    t.integer  "phase_id",                                null: false
    t.boolean  "completed",              default: false,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",       limit: 255,                  null: false
    t.json     "body",                   default: [],     null: false
  end

  add_index "tasks", ["id", "type"], name: "index_tasks_on_id_and_type", using: :btree
  add_index "tasks", ["phase_id"], name: "index_tasks_on_phase_id", using: :btree

  create_table "user_flows", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "flow_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
  end

  add_index "user_roles", ["role_id"], name: "index_user_roles_on_role_id", using: :btree
  add_index "user_roles", ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", using: :btree
  add_index "user_roles", ["user_id"], name: "index_user_roles_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             limit: 255, default: "",    null: false
    t.string   "last_name",              limit: 255, default: "",    null: false
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",               limit: 255
    t.boolean  "site_admin",                         default: false, null: false
    t.string   "avatar",                 limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
