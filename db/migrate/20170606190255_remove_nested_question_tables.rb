class RemoveNestedQuestionTables < ActiveRecord::Migration
  def up
    drop_table :nested_questions
    drop_table :nested_question_answers
  end

  def down
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
      t.integer  "paper_id"
      t.datetime "deleted_at"
    end

    add_index "nested_question_answers", ["decision_id"], name: "index_nested_question_answers_on_decision_id", using: :btree
    add_index "nested_question_answers", ["paper_id"], name: "index_nested_question_answers_on_paper_id", using: :btree

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
      t.datetime "deleted_at"
    end

    add_index "nested_questions", ["ident"], name: "index_nested_questions_on_ident", unique: true, using: :btree
    add_index "nested_questions", ["lft"], name: "index_nested_questions_on_lft", using: :btree
    add_index "nested_questions", ["parent_id"], name: "index_nested_questions_on_parent_id", using: :btree
    add_index "nested_questions", ["rgt"], name: "index_nested_questions_on_rgt", using: :btree
  end
end
