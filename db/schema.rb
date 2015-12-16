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

ActiveRecord::Schema.define(version: 20151203181938) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"
  enable_extension "pg_stat_statements"

  create_table "activities", force: :cascade do |t|
    t.string   "feed_name"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "activity_key"
    t.string   "message"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["subject_id"], name: "index_activities_on_subject_id", using: :btree
  add_index "activities", ["subject_type"], name: "index_activities_on_subject_type", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "affiliations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "department"
    t.string   "title"
    t.string   "country"
    t.string   "ringgold_id"
  end

  add_index "affiliations", ["user_id"], name: "index_affiliations_on_user_id", using: :btree

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "file"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "caption"
    t.string   "status",     default: "processing"
    t.string   "kind"
  end

  create_table "authors", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "paper_id"
    t.integer  "authors_task_id"
    t.string   "middle_initial"
    t.string   "email"
    t.string   "department"
    t.string   "title"
    t.string   "affiliation"
    t.string   "secondary_affiliation"
    t.string   "ringgold_id"
    t.string   "secondary_ringgold_id"
  end

  create_table "bibitems", force: :cascade do |t|
    t.integer  "paper_id"
    t.string   "format"
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "bibitems", ["paper_id"], name: "index_bibitems_on_paper_id", using: :btree

  create_table "comment_looks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
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
    t.string  "provider"
    t.string  "uid"
    t.integer "user_id"
  end

  add_index "credentials", ["uid", "provider"], name: "index_credentials_on_uid_and_provider", using: :btree

  create_table "decisions", force: :cascade do |t|
    t.integer  "paper_id"
    t.integer  "revision_number", default: 0
    t.text     "letter"
    t.string   "verdict"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "author_response"
  end

  add_index "decisions", ["paper_id", "revision_number"], name: "index_decisions_on_paper_id_and_revision_number", unique: true, using: :btree
  add_index "decisions", ["paper_id"], name: "index_decisions_on_paper_id", using: :btree

  create_table "discussion_participants", force: :cascade do |t|
    t.integer  "discussion_topic_id"
    t.integer  "user_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "discussion_participants", ["discussion_topic_id"], name: "index_discussion_participants_on_discussion_topic_id", using: :btree
  add_index "discussion_participants", ["user_id"], name: "index_discussion_participants_on_user_id", using: :btree

  create_table "discussion_replies", force: :cascade do |t|
    t.text     "body"
    t.integer  "discussion_topic_id"
    t.integer  "replier_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "discussion_replies", ["discussion_topic_id"], name: "index_discussion_replies_on_discussion_topic_id", using: :btree
  add_index "discussion_replies", ["replier_id"], name: "index_discussion_replies_on_replier_id", using: :btree

  create_table "discussion_topics", force: :cascade do |t|
    t.string   "title"
    t.integer  "paper_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "discussion_topics", ["paper_id"], name: "index_discussion_topics_on_paper_id", using: :btree

  create_table "figures", force: :cascade do |t|
    t.string   "attachment"
    t.integer  "paper_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "caption"
    t.string   "status",     default: "processing"
  end

  add_index "figures", ["paper_id"], name: "index_figures_on_paper_id", using: :btree

  create_table "flows", force: :cascade do |t|
    t.string  "title"
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
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "decision_id"
    t.string   "information"
    t.text     "body"
  end

  add_index "invitations", ["actor_id"], name: "index_invitations_on_actor_id", using: :btree
  add_index "invitations", ["code"], name: "index_invitations_on_code", unique: true, using: :btree
  add_index "invitations", ["decision_id"], name: "index_invitations_on_decision_id", using: :btree
  add_index "invitations", ["email"], name: "index_invitations_on_email", using: :btree
  add_index "invitations", ["invitee_id"], name: "index_invitations_on_invitee_id", using: :btree
  add_index "invitations", ["task_id"], name: "index_invitations_on_task_id", using: :btree

  create_table "journal_task_types", force: :cascade do |t|
    t.integer "journal_id"
    t.string  "title"
    t.string  "role"
    t.string  "kind"
  end

  add_index "journal_task_types", ["journal_id"], name: "index_journal_task_types_on_journal_id", using: :btree

  create_table "journals", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.string   "epub_cover"
    t.text     "epub_css"
    t.text     "pdf_css"
    t.text     "manuscript_css"
    t.text     "description"
    t.string   "doi_publisher_prefix"
    t.string   "doi_journal_prefix"
    t.string   "last_doi_issued",      default: "0"
  end

  create_table "manuscript_manager_templates", force: :cascade do |t|
    t.string  "paper_type"
    t.integer "journal_id"
  end

  add_index "manuscript_manager_templates", ["journal_id"], name: "index_manuscript_manager_templates_on_journal_id", using: :btree

  create_table "nested_question_answers", force: :cascade do |t|
    t.integer  "nested_question_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.text     "value"
    t.string   "value_type",         null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.json     "additional_data"
    t.integer  "decision_id"
  end

  add_index "nested_question_answers", ["decision_id"], name: "index_nested_question_answers_on_decision_id", using: :btree

  create_table "nested_questions", force: :cascade do |t|
    t.string   "text"
    t.string   "value_type", null: false
    t.string   "ident",      null: false
    t.integer  "parent_id"
    t.integer  "lft",        null: false
    t.integer  "rgt",        null: false
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "owner_type"
    t.integer  "owner_id"
  end

  add_index "nested_questions", ["lft"], name: "index_nested_questions_on_lft", using: :btree
  add_index "nested_questions", ["parent_id"], name: "index_nested_questions_on_parent_id", using: :btree
  add_index "nested_questions", ["rgt"], name: "index_nested_questions_on_rgt", using: :btree

  create_table "paper_roles", force: :cascade do |t|
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

  create_table "papers", force: :cascade do |t|
    t.string   "short_title"
    t.text     "title"
    t.text     "abstract",                 default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "paper_type"
    t.integer  "journal_id",                               null: false
    t.text     "decision_letter"
    t.datetime "published_at"
    t.integer  "striking_image_id"
    t.boolean  "editable",                 default: true
    t.text     "doi"
    t.string   "publishing_state"
    t.datetime "submitted_at"
    t.string   "salesforce_manuscript_id"
    t.jsonb    "withdrawals",              default: [],                 array: true
    t.boolean  "active",                   default: true
    t.boolean  "gradual_engagement",       default: false
    t.datetime "first_submitted_at"
    t.datetime "accepted_at"
  end

  add_index "papers", ["doi"], name: "index_papers_on_doi", unique: true, using: :btree
  add_index "papers", ["journal_id"], name: "index_papers_on_journal_id", using: :btree
  add_index "papers", ["publishing_state"], name: "index_papers_on_publishing_state", using: :btree
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
    t.string   "name"
    t.integer  "manuscript_manager_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "phase_templates", ["manuscript_manager_template_id"], name: "index_phase_templates_on_manuscript_manager_template_id", using: :btree

  create_table "phases", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "paper_id",   null: false
  end

  add_index "phases", ["paper_id"], name: "index_phases_on_paper_id", using: :btree

  create_table "question_attachments", force: :cascade do |t|
    t.integer  "nested_question_answer_id"
    t.string   "attachment"
    t.string   "title"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_attachments", ["nested_question_answer_id"], name: "index_question_attachments_on_nested_question_answer_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "journal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "can_administer_journal",                default: false,    null: false
    t.boolean  "can_view_assigned_manuscript_managers", default: false,    null: false
    t.boolean  "can_view_all_manuscript_managers",      default: false,    null: false
    t.string   "kind",                                  default: "custom", null: false
    t.boolean  "can_view_flow_manager",                 default: false,    null: false
  end

  add_index "roles", ["kind"], name: "index_roles_on_kind", using: :btree

  create_table "snapshots", force: :cascade do |t|
    t.string   "source_type"
    t.integer  "source_id"
    t.integer  "paper_id"
    t.integer  "major_version"
    t.integer  "minor_version"
    t.json     "contents"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "supporting_information_files", force: :cascade do |t|
    t.integer  "paper_id"
    t.string   "title"
    t.string   "caption"
    t.string   "attachment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",      default: "processing"
    t.boolean  "publishable", default: true
    t.string   "token"
  end

  add_index "supporting_information_files", ["paper_id"], name: "index_supporting_information_files_on_paper_id", using: :btree
  add_index "supporting_information_files", ["token"], name: "index_supporting_information_files_on_token", unique: true, using: :btree

  create_table "tables", force: :cascade do |t|
    t.integer  "paper_id"
    t.string   "title"
    t.string   "caption"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tables", ["paper_id"], name: "index_tables_on_paper_id", using: :btree

  create_table "tahi_standard_tasks_apex_deliveries", force: :cascade do |t|
    t.integer  "paper_id"
    t.integer  "task_id"
    t.integer  "user_id"
    t.string   "state"
    t.string   "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tahi_standard_tasks_funded_authors", force: :cascade do |t|
    t.integer "author_id"
    t.integer "funder_id"
  end

  add_index "tahi_standard_tasks_funded_authors", ["author_id", "funder_id"], name: "funded_authors_unique_index", unique: true, using: :btree
  add_index "tahi_standard_tasks_funded_authors", ["author_id"], name: "index_tahi_standard_tasks_funded_authors_on_author_id", using: :btree
  add_index "tahi_standard_tasks_funded_authors", ["funder_id"], name: "index_tahi_standard_tasks_funded_authors_on_funder_id", using: :btree

  create_table "tahi_standard_tasks_funders", force: :cascade do |t|
    t.string   "name"
    t.string   "grant_number"
    t.string   "website"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tahi_standard_tasks_funders", ["task_id"], name: "index_tahi_standard_tasks_funders_on_task_id", using: :btree

  create_table "tahi_standard_tasks_reviewer_recommendations", force: :cascade do |t|
    t.integer  "reviewer_recommendations_task_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_initial"
    t.string   "email",                            null: false
    t.string   "department"
    t.string   "title"
    t.string   "affiliation"
    t.string   "recommend_or_oppose"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ringgold_id"
  end

  create_table "task_templates", force: :cascade do |t|
    t.integer "journal_task_type_id"
    t.integer "phase_template_id"
    t.json    "template",             default: [], null: false
    t.string  "title"
    t.integer "position"
  end

  add_index "task_templates", ["journal_task_type_id"], name: "index_task_templates_on_journal_task_type_id", using: :btree
  add_index "task_templates", ["phase_template_id"], name: "index_task_templates_on_phase_template_id", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "title",                       null: false
    t.string   "type",       default: "Task"
    t.integer  "phase_id",                    null: false
    t.boolean  "completed",  default: false,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                        null: false
    t.json     "body",       default: [],     null: false
    t.integer  "position",   default: 0
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
    t.string   "em_guid"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "versioned_texts", force: :cascade do |t|
    t.integer  "submitting_user_id"
    t.integer  "paper_id",                        null: false
    t.integer  "major_version",                   null: false
    t.integer  "minor_version",                   null: false
    t.text     "text",               default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "source"
  end

  add_index "versioned_texts", ["minor_version", "major_version", "paper_id"], name: "unique_version", unique: true, using: :btree

  add_foreign_key "decisions", "papers"
  add_foreign_key "discussion_participants", "discussion_topics"
  add_foreign_key "discussion_participants", "users"
  add_foreign_key "discussion_replies", "discussion_topics"
  add_foreign_key "discussion_topics", "papers"
end
