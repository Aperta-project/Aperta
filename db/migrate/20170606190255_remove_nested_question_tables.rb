# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
