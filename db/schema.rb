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

ActiveRecord::Schema.define(version: 20170815220450) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "pg_trgm"
  enable_extension "unaccent"

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

  create_table "answers", force: :cascade do |t|
    t.integer  "card_content_id"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "paper_id"
    t.string   "value"
    t.jsonb    "additional_data"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "deleted_at"
    t.string   "annotation"
  end

  add_index "answers", ["card_content_id"], name: "index_answers_on_card_content_id", using: :btree
  add_index "answers", ["paper_id"], name: "index_answers_on_paper_id", using: :btree

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignments", force: :cascade do |t|
    t.integer  "user_id",          null: false
    t.integer  "role_id",          null: false
    t.integer  "assigned_to_id",   null: false
    t.string   "assigned_to_type", null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "assignments", ["assigned_to_id"], name: "index_assignments_on_assigned_to_id", using: :btree
  add_index "assignments", ["assigned_to_type"], name: "index_assignments_on_assigned_to_type", using: :btree
  add_index "assignments", ["role_id"], name: "index_assignments_on_role_id", using: :btree
  add_index "assignments", ["user_id", "role_id", "assigned_to_type", "assigned_to_id"], name: "uniq_assigment_idx", unique: true, using: :btree
  add_index "assignments", ["user_id"], name: "index_assignments_on_user_id", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "file"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                                     comment: "Contains HTML"
    t.string   "caption",                                   comment: "Contains HTML"
    t.string   "status",             default: "processing"
    t.string   "file_type"
    t.text     "s3_dir"
    t.string   "type"
    t.integer  "old_id"
    t.string   "owner_type"
    t.integer  "paper_id"
    t.string   "category"
    t.string   "label"
    t.boolean  "publishable"
    t.string   "file_hash"
    t.string   "previous_file_hash"
    t.integer  "uploaded_by_id"
    t.text     "error_message"
    t.text     "error_backtrace"
    t.datetime "errored_at"
    t.string   "pending_url"
  end

  add_index "attachments", ["owner_id", "owner_type"], name: "index_attachments_on_owner_id_and_owner_type", using: :btree
  add_index "attachments", ["paper_id"], name: "index_attachments_on_paper_id", using: :btree

  create_table "author_list_items", force: :cascade do |t|
    t.integer  "position"
    t.integer  "author_id",   null: false
    t.string   "author_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "paper_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "middle_initial"
    t.string   "email"
    t.string   "department"
    t.string   "title"
    t.string   "affiliation"
    t.string   "secondary_affiliation"
    t.string   "ringgold_id"
    t.string   "secondary_ringgold_id"
    t.string   "author_initial"
    t.string   "current_address_street"
    t.string   "current_address_street2"
    t.string   "current_address_city"
    t.string   "current_address_state"
    t.string   "current_address_country"
    t.string   "current_address_postal"
    t.integer  "user_id"
    t.string   "token"
    t.string   "co_author_state"
    t.datetime "co_author_state_modified_at"
    t.integer  "co_author_state_modified_by_id"
    t.integer  "card_version_id",                null: false
  end

  add_index "authors", ["token"], name: "index_authors_on_token", unique: true, using: :btree

  create_table "billing_log_reports", force: :cascade do |t|
    t.string   "csv_file"
    t.date     "from_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "billing_logs", force: :cascade do |t|
    t.string   "ned_id"
    t.integer  "documentid",                     null: false
    t.string   "title"
    t.string   "firstname"
    t.string   "middlename"
    t.string   "lastname"
    t.string   "institute"
    t.string   "department"
    t.string   "address1"
    t.string   "address2"
    t.string   "address3"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.string   "country"
    t.string   "phone1"
    t.string   "phone2"
    t.integer  "fax"
    t.string   "email"
    t.integer  "journal",                        null: false
    t.string   "pubdnumber"
    t.string   "doi"
    t.string   "dtitle"
    t.string   "fundRef"
    t.string   "collectionID"
    t.string   "collection"
    t.date     "original_submission_start_date"
    t.string   "direct_bill_response"
    t.date     "date_first_entered_production"
    t.string   "gpi_response"
    t.date     "final_dispo_accept"
    t.string   "category"
    t.date     "import_date"
    t.string   "csv_file"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "corresponding_author_ned_id"
    t.integer  "corresponding_author_ned_email"
  end

  add_index "billing_logs", ["corresponding_author_ned_email"], name: "index_billing_logs_on_corresponding_author_ned_email", using: :btree
  add_index "billing_logs", ["corresponding_author_ned_id"], name: "index_billing_logs_on_corresponding_author_ned_id", using: :btree
  add_index "billing_logs", ["documentid"], name: "index_billing_logs_on_documentid", using: :btree
  add_index "billing_logs", ["journal"], name: "index_billing_logs_on_journal", using: :btree
  add_index "billing_logs", ["ned_id"], name: "index_billing_logs_on_ned_id", using: :btree

  create_table "card_content_validations", force: :cascade do |t|
    t.string   "validator"
    t.string   "validation_type", null: false
    t.text     "error_message"
    t.integer  "card_content_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "card_content_validations", ["card_content_id"], name: "index_card_content_validations_on_card_content_id", using: :btree
  add_index "card_content_validations", ["deleted_at"], name: "index_card_content_validations_on_deleted_at", using: :btree

  create_table "card_contents", force: :cascade do |t|
    t.string   "ident"
    t.integer  "parent_id"
    t.integer  "lft",                                        null: false
    t.integer  "rgt",                                        null: false
    t.string   "text"
    t.string   "value_type"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.datetime "deleted_at"
    t.integer  "card_version_id",                            null: false
    t.string   "content_type"
    t.string   "placeholder"
    t.jsonb    "possible_values"
    t.string   "visible_with_parent_answer"
    t.string   "label"
    t.string   "default_answer_value"
    t.boolean  "allow_multiple_uploads"
    t.boolean  "allow_file_captions"
    t.boolean  "allow_annotations"
    t.string   "instruction_text"
    t.string   "editor_style"
    t.boolean  "required_field"
  end

  add_index "card_contents", ["ident"], name: "index_card_contents_on_ident", using: :btree
  add_index "card_contents", ["lft"], name: "index_card_contents_on_lft", using: :btree
  add_index "card_contents", ["parent_id"], name: "index_card_contents_on_parent_id", using: :btree
  add_index "card_contents", ["rgt"], name: "index_card_contents_on_rgt", using: :btree

  create_table "card_versions", force: :cascade do |t|
    t.integer  "version",                                 null: false
    t.integer  "card_id",                                 null: false
    t.datetime "deleted_at"
    t.boolean  "required_for_submission", default: false, null: false
    t.datetime "published_at"
    t.integer  "published_by_id"
    t.string   "history_entry"
    t.boolean  "workflow_display_only",   default: false, null: false
  end

  add_index "card_versions", ["card_id"], name: "index_card_versions_on_card_id", using: :btree
  add_index "card_versions", ["published_by_id"], name: "index_card_versions_on_published_by_id", using: :btree
  add_index "card_versions", ["version"], name: "index_card_versions_on_version", using: :btree

  create_table "cards", force: :cascade do |t|
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "deleted_at"
    t.string   "name"
    t.integer  "journal_id"
    t.integer  "latest_version", default: 1, null: false
    t.datetime "archived_at"
    t.string   "state",                      null: false
  end

  add_index "cards", ["journal_id"], name: "index_cards_on_journal_id", using: :btree
  add_index "cards", ["state"], name: "index_cards_on_state", using: :btree

  create_table "comment_looks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comment_looks", ["comment_id"], name: "index_comment_looks_on_comment_id", using: :btree
  add_index "comment_looks", ["user_id"], name: "index_comment_looks_on_user_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "body",         comment: "Contains HTML"
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
    t.text     "letter",                                       comment: "Contains HTML"
    t.string   "verdict"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "author_response"
    t.datetime "registered_at"
    t.integer  "minor_version"
    t.integer  "major_version"
    t.boolean  "initial",         default: false, null: false
    t.boolean  "rescinded",       default: false
  end

  add_index "decisions", ["minor_version", "major_version", "paper_id"], name: "unique_decision_version", unique: true, using: :btree
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
    t.text     "body",                             comment: "Contains HTML"
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

  create_table "due_datetimes", force: :cascade do |t|
    t.integer  "due_id"
    t.string   "due_type"
    t.datetime "due_at"
    t.datetime "originally_due_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "due_datetimes", ["due_type", "due_id"], name: "index_due_datetimes_on_due_type_and_due_id", using: :btree

  create_table "email_logs", force: :cascade do |t|
    t.string   "sender"
    t.string   "recipients"
    t.string   "subject"
    t.string   "message_id"
    t.text     "raw_source"
    t.string   "status"
    t.string   "error_message"
    t.datetime "errored_at"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "task_id"
    t.integer  "paper_id"
    t.integer  "journal_id"
    t.jsonb    "additional_context"
    t.text     "body"
    t.boolean  "external"
    t.string   "description"
    t.string   "cc"
    t.string   "bcc"
    t.string   "manuscript_status"
    t.string   "manuscript_version"
    t.integer  "versioned_text_id"
  end

  add_index "email_logs", ["journal_id"], name: "index_email_logs_on_journal_id", using: :btree
  add_index "email_logs", ["message_id"], name: "index_email_logs_on_message_id", using: :btree
  add_index "email_logs", ["paper_id"], name: "index_email_logs_on_paper_id", using: :btree
  add_index "email_logs", ["task_id"], name: "index_email_logs_on_task_id", using: :btree

  create_table "feature_flags", id: false, force: :cascade do |t|
    t.string  "name",   null: false
    t.boolean "active", null: false
  end

  create_table "group_authors", force: :cascade do |t|
    t.string   "contact_first_name"
    t.string   "contact_middle_name"
    t.string   "contact_last_name"
    t.string   "contact_email"
    t.string   "name"
    t.string   "initial"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "co_author_state"
    t.datetime "co_author_state_modified_at"
    t.integer  "co_author_state_modified_by_id"
    t.integer  "card_version_id",                null: false
  end

  add_index "group_authors", ["token"], name: "index_group_authors_on_token", unique: true, using: :btree

  create_table "invitation_queues", force: :cascade do |t|
    t.integer  "task_id"
    t.integer  "decision_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", force: :cascade do |t|
    t.string   "email"
    t.integer  "task_id"
    t.integer  "invitee_id"
    t.integer  "actor_id"
    t.string   "state",                default: "pending", null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "decision_id"
    t.string   "information"
    t.text     "body",                                                  comment: "Contains HTML"
    t.integer  "inviter_id"
    t.string   "invitee_role",                             null: false
    t.text     "decline_reason",                                        comment: "Contains HTML"
    t.text     "reviewer_suggestions",                                  comment: "Contains HTML"
    t.string   "token",                                    null: false
    t.integer  "primary_id"
    t.datetime "invited_at"
    t.datetime "declined_at"
    t.datetime "accepted_at"
    t.datetime "rescinded_at"
    t.integer  "position",                                 null: false
    t.integer  "invitation_queue_id"
  end

  add_index "invitations", ["actor_id"], name: "index_invitations_on_actor_id", using: :btree
  add_index "invitations", ["decision_id"], name: "index_invitations_on_decision_id", using: :btree
  add_index "invitations", ["email"], name: "index_invitations_on_email", using: :btree
  add_index "invitations", ["invitation_queue_id"], name: "index_invitations_on_invitation_queue_id", using: :btree
  add_index "invitations", ["invitee_id"], name: "index_invitations_on_invitee_id", using: :btree
  add_index "invitations", ["primary_id"], name: "index_invitations_on_primary_id", using: :btree
  add_index "invitations", ["state"], name: "index_invitations_on_state", using: :btree
  add_index "invitations", ["task_id"], name: "index_invitations_on_task_id", using: :btree
  add_index "invitations", ["token"], name: "index_invitations_on_token", unique: true, using: :btree

  create_table "journal_task_types", force: :cascade do |t|
    t.integer "journal_id"
    t.string  "title"
    t.string  "kind"
    t.boolean "system_generated"
    t.string  "role_hint"
  end

  add_index "journal_task_types", ["journal_id"], name: "index_journal_task_types_on_journal_id", using: :btree

  create_table "journals", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo"
    t.text     "pdf_css"
    t.text     "manuscript_css"
    t.text     "description"
    t.string   "doi_publisher_prefix",                 null: false
    t.string   "doi_journal_prefix",                   null: false
    t.string   "last_doi_issued",      default: "0",   null: false
    t.string   "staff_email"
    t.string   "reviewer_email_bcc"
    t.string   "editor_email_bcc"
    t.boolean  "pdf_allowed",          default: false
  end

  add_index "journals", ["doi_publisher_prefix", "doi_journal_prefix"], name: "unique_doi", unique: true, using: :btree

  create_table "letter_templates", force: :cascade do |t|
    t.string   "name"
    t.string   "category"
    t.string   "to"
    t.string   "subject"
    t.text     "body"
    t.integer  "journal_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manuscript_manager_templates", force: :cascade do |t|
    t.string   "paper_type"
    t.integer  "journal_id"
    t.boolean  "uses_research_article_reviewer_report", default: false
    t.datetime "updated_at"
    t.datetime "created_at"
  end

  add_index "manuscript_manager_templates", ["journal_id"], name: "index_manuscript_manager_templates_on_journal_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "paper_id"
    t.integer  "user_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "notifications", ["paper_id"], name: "index_notifications_on_paper_id", using: :btree
  add_index "notifications", ["target_id", "target_type"], name: "index_notifications_on_target_id_and_target_type", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "orcid_accounts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "access_token"
    t.string   "refresh_token"
    t.string   "identifier"
    t.datetime "expires_at"
    t.string   "name"
    t.string   "scope"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "orcid_accounts", ["user_id"], name: "index_orcid_accounts_on_user_id", using: :btree

  create_table "paper_tracker_queries", force: :cascade do |t|
    t.string   "query"
    t.string   "title"
    t.boolean  "deleted",    default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "papers", force: :cascade do |t|
    t.text     "abstract",                              default: "",                 comment: "Contains HTML"
    t.text     "title",                                                 null: false, comment: "Contains HTML"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "paper_type"
    t.integer  "journal_id",                                            null: false
    t.datetime "published_at"
    t.integer  "striking_image_id"
    t.boolean  "editable",                              default: true
    t.text     "doi"
    t.string   "publishing_state"
    t.datetime "submitted_at"
    t.string   "salesforce_manuscript_id"
    t.boolean  "active",                                default: true
    t.boolean  "gradual_engagement",                    default: false
    t.datetime "first_submitted_at"
    t.datetime "accepted_at"
    t.string   "striking_image_type"
    t.datetime "state_updated_at"
    t.boolean  "processing",                            default: false
    t.boolean  "uses_research_article_reviewer_report", default: false
    t.string   "short_doi"
    t.boolean  "number_reviewer_reports",               default: false, null: false
    t.boolean  "legends_allowed",                       default: false, null: false
  end

  add_index "papers", ["doi"], name: "index_papers_on_doi", unique: true, using: :btree
  add_index "papers", ["journal_id"], name: "index_papers_on_journal_id", using: :btree
  add_index "papers", ["publishing_state"], name: "index_papers_on_publishing_state", using: :btree
  add_index "papers", ["short_doi"], name: "index_papers_on_short_doi", unique: true, using: :btree
  add_index "papers", ["user_id"], name: "index_papers_on_user_id", using: :btree

  create_table "permission_states", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "permission_states_permissions", force: :cascade do |t|
    t.integer  "permission_id",       null: false
    t.integer  "permission_state_id", null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "permission_states_permissions", ["permission_id"], name: "index_permission_states_permissions_on_permission_id", using: :btree
  add_index "permission_states_permissions", ["permission_state_id", "permission_id"], name: "permission_states_ids_idx", unique: true, using: :btree

  create_table "permissions", force: :cascade do |t|
    t.string   "action",            null: false
    t.string   "applies_to",        null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "filter_by_card_id"
  end

  add_index "permissions", ["action", "applies_to"], name: "index_permissions_on_action_and_applies_to", using: :btree
  add_index "permissions", ["applies_to"], name: "index_permissions_on_applies_to", using: :btree

  create_table "permissions_roles", force: :cascade do |t|
    t.integer  "permission_id", null: false
    t.integer  "role_id",       null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "permissions_roles", ["permission_id"], name: "index_permissions_roles_on_permission_id", using: :btree
  add_index "permissions_roles", ["role_id", "permission_id"], name: "index_permissions_roles_on_role_id_and_permission_id", unique: true, using: :btree
  add_index "permissions_roles", ["role_id"], name: "index_permissions_roles_on_role_id", using: :btree

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

  create_table "possible_setting_values", force: :cascade do |t|
    t.integer  "setting_template_id"
    t.string   "value_type",          default: "string", null: false
    t.string   "string_value"
    t.boolean  "boolean_value"
    t.integer  "integer_value"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "possible_setting_values", ["setting_template_id"], name: "index_possible_setting_values_on_setting_template_id", using: :btree

  create_table "reference_jsons", force: :cascade do |t|
    t.text     "name"
    t.jsonb    "items",      default: [],              array: true
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "related_articles", force: :cascade do |t|
    t.integer  "paper_id"
    t.string   "linked_doi"
    t.string   "linked_title",              comment: "Contains HTML"
    t.string   "additional_info"
    t.boolean  "send_manuscripts_together"
    t.text     "send_link_to_apex"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "related_articles", ["paper_id"], name: "index_related_articles_on_paper_id", using: :btree

  create_table "resource_tokens", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "token"
    t.jsonb    "version_urls", default: {}, null: false
    t.string   "default_url"
  end

  add_index "resource_tokens", ["owner_id", "owner_type"], name: "index_resource_tokens_on_owner_id_and_owner_type", using: :btree
  add_index "resource_tokens", ["token"], name: "index_resource_tokens_on_token", using: :btree

  create_table "reviewer_numbers", force: :cascade do |t|
    t.integer  "paper_id",   null: false
    t.integer  "user_id",    null: false
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviewer_numbers", ["paper_id", "number"], name: "index_reviewer_numbers_on_paper_id_and_number", unique: true, using: :btree
  add_index "reviewer_numbers", ["paper_id", "user_id"], name: "index_reviewer_numbers_on_paper_id_and_user_id", unique: true, using: :btree
  add_index "reviewer_numbers", ["paper_id"], name: "index_reviewer_numbers_on_paper_id", using: :btree
  add_index "reviewer_numbers", ["user_id"], name: "index_reviewer_numbers_on_user_id", using: :btree

  create_table "reviewer_reports", force: :cascade do |t|
    t.integer  "task_id",                         null: false
    t.integer  "decision_id",                     null: false
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "created_in_7993", default: false
    t.integer  "card_version_id",                 null: false
    t.string   "state"
    t.datetime "submitted_at"
  end

  add_index "reviewer_reports", ["task_id", "user_id", "decision_id"], name: "one_report_per_round", unique: true, using: :btree
  add_index "reviewer_reports", ["task_id"], name: "index_reviewer_reports_on_task_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",                                   null: false
    t.integer  "journal_id"
    t.boolean  "participates_in_papers", default: false, null: false
    t.boolean  "participates_in_tasks",  default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "assigned_to_type_hint"
  end

  add_index "roles", ["assigned_to_type_hint"], name: "index_roles_on_assigned_to_type_hint", using: :btree
  add_index "roles", ["journal_id", "name"], name: "index_roles_on_journal_id_and_name", unique: true, using: :btree
  add_index "roles", ["participates_in_papers"], name: "index_roles_on_participates_in_papers", using: :btree
  add_index "roles", ["participates_in_tasks"], name: "index_roles_on_participates_in_tasks", using: :btree

  create_table "s3_migrations", force: :cascade do |t|
    t.text     "source_url",                        null: false
    t.text     "destination_url"
    t.string   "attachment_type",                   null: false
    t.integer  "attachment_id",                     null: false
    t.boolean  "version",                           null: false
    t.string   "state",           default: "ready"
    t.text     "error_message"
    t.text     "error_backtrace"
    t.datetime "errored_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scheduled_events", force: :cascade do |t|
    t.datetime "dispatch_at"
    t.string   "state"
    t.string   "name"
    t.integer  "due_datetime_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "owner_type"
    t.integer  "owner_id"
  end

  add_index "scheduled_events", ["due_datetime_id"], name: "index_scheduled_events_on_due_datetime_id", using: :btree

  create_table "scratches", force: :cascade do |t|
    t.string   "contents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "setting_templates", force: :cascade do |t|
    t.string  "key"
    t.string  "setting_klass"
    t.string  "setting_name"
    t.boolean "global"
    t.integer "journal_id"
    t.string  "value_type",    default: "string", null: false
    t.string  "string_value"
    t.boolean "boolean_value"
    t.integer "integer_value"
  end

  add_index "setting_templates", ["key"], name: "index_setting_templates_on_key", using: :btree

  create_table "settings", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "name"
    t.string   "string_value"
    t.string   "type"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "value_type",          default: "string", null: false
    t.integer  "integer_value"
    t.boolean  "boolean_value"
    t.integer  "setting_template_id"
  end

  add_index "settings", ["setting_template_id"], name: "index_settings_on_setting_template_id", using: :btree

  create_table "similarity_checks", force: :cascade do |t|
    t.integer  "ithenticate_document_id"
    t.datetime "ithenticate_report_completed_at"
    t.datetime "timeout_at"
    t.string   "document_s3_url"
    t.integer  "ithenticate_report_id"
    t.integer  "ithenticate_score"
    t.integer  "versioned_text_id",                               null: false
    t.string   "state",                                           null: false
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "error_message"
    t.boolean  "dismissed",                       default: false
    t.boolean  "automatic",                       default: false, null: false
  end

  create_table "snapshots", force: :cascade do |t|
    t.string   "source_type"
    t.integer  "source_id"
    t.integer  "paper_id"
    t.integer  "major_version"
    t.integer  "minor_version"
    t.json     "contents"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "key"
  end

  add_index "snapshots", ["key"], name: "index_snapshots_on_key", using: :btree

  create_table "systems", force: :cascade do |t|
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "tahi_standard_tasks_export_deliveries", force: :cascade do |t|
    t.integer  "paper_id"
    t.integer  "task_id"
    t.integer  "user_id"
    t.string   "state"
    t.string   "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "destination",   null: false
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
    t.text     "additional_comments"
    t.integer  "card_version_id",     null: false
  end

  add_index "tahi_standard_tasks_funders", ["task_id"], name: "index_tahi_standard_tasks_funders_on_task_id", using: :btree

  create_table "tahi_standard_tasks_reviewer_recommendations", force: :cascade do |t|
    t.integer  "reviewer_recommendations_task_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_initial"
    t.string   "email"
    t.string   "department"
    t.string   "title"
    t.string   "affiliation"
    t.string   "recommend_or_oppose"
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ringgold_id"
    t.integer  "card_version_id",                  null: false
  end

  create_table "task_templates", force: :cascade do |t|
    t.integer "journal_task_type_id"
    t.integer "phase_template_id"
    t.string  "title"
    t.json    "template",             default: [], null: false
    t.integer "position"
    t.integer "card_id"
  end

  add_index "task_templates", ["card_id"], name: "index_task_templates_on_card_id", using: :btree
  add_index "task_templates", ["journal_task_type_id"], name: "index_task_templates_on_journal_task_type_id", using: :btree
  add_index "task_templates", ["phase_template_id"], name: "index_task_templates_on_phase_template_id", using: :btree

  create_table "tasks", force: :cascade do |t|
    t.string   "title",                             null: false
    t.string   "type",             default: "Task"
    t.integer  "phase_id",                          null: false
    t.boolean  "completed",        default: false,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.json     "body",             default: [],     null: false
    t.integer  "position",         default: 0
    t.integer  "paper_id",                          null: false
    t.datetime "completed_at"
    t.integer  "card_version_id",                   null: false
    t.integer  "task_template_id"
  end

  add_index "tasks", ["id", "type"], name: "index_tasks_on_id_and_type", using: :btree
  add_index "tasks", ["paper_id"], name: "index_tasks_on_paper_id", using: :btree
  add_index "tasks", ["phase_id"], name: "index_tasks_on_phase_id", using: :btree
  add_index "tasks", ["task_template_id"], name: "index_tasks_on_task_template_id", using: :btree
  add_index "tasks", ["title"], name: "index_tasks_on_title", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             default: "", null: false
    t.string   "last_name",              default: "", null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "avatar"
    t.integer  "ned_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "versioned_texts", force: :cascade do |t|
    t.integer  "submitting_user_id"
    t.integer  "paper_id",                         null: false
    t.integer  "major_version"
    t.integer  "minor_version"
    t.text     "text",                default: "",              comment: "Contains HTML"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "original_text",                                 comment: "Contains HTML"
    t.string   "file_type"
    t.string   "manuscript_s3_path"
    t.string   "manuscript_filename"
    t.string   "sourcefile_s3_path"
    t.string   "sourcefile_filename"
  end

  add_index "versioned_texts", ["minor_version", "major_version", "paper_id"], name: "unique_version", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "withdrawals", force: :cascade do |t|
    t.string   "reason"
    t.integer  "paper_id",                                 null: false
    t.integer  "withdrawn_by_user_id"
    t.string   "previous_publishing_state",                null: false
    t.boolean  "previous_editable",         default: true, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "withdrawals", ["paper_id"], name: "index_withdrawals_on_paper_id", using: :btree

  add_foreign_key "answers", "card_contents"
  add_foreign_key "author_list_items", "papers"
  add_foreign_key "authors", "users", column: "co_author_state_modified_by_id"
  add_foreign_key "card_content_validations", "card_contents"
  add_foreign_key "card_versions", "cards"
  add_foreign_key "decisions", "papers"
  add_foreign_key "discussion_participants", "discussion_topics"
  add_foreign_key "discussion_participants", "users"
  add_foreign_key "discussion_replies", "discussion_topics"
  add_foreign_key "discussion_topics", "papers"
  add_foreign_key "group_authors", "users", column: "co_author_state_modified_by_id"
  add_foreign_key "notifications", "papers"
  add_foreign_key "notifications", "users"
  add_foreign_key "permissions", "cards", column: "filter_by_card_id"
  add_foreign_key "scheduled_events", "due_datetimes"
  add_foreign_key "settings", "setting_templates"
  add_foreign_key "similarity_checks", "versioned_texts"
  add_foreign_key "task_templates", "cards"
end
