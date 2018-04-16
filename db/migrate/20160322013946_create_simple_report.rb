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

# Adds SimpleReports table, used to track historical state information for
# reporting purposes
class CreateSimpleReport < ActiveRecord::Migration
  def change
    create_table :simple_reports do |t|
      t.timestamps
      t.integer :initially_submitted, default: 0, null: false
      t.integer :fully_submitted, default: 0, null: false
      t.integer :invited_for_full_submission, default: 0, null: false
      t.integer :checking, default: 0, null: false
      t.integer :in_revision, default: 0, null: false
      t.integer :accepted, default: 0, null: false
      t.integer :withdrawn, default: 0, null: false
      t.integer :rejected, default: 0, null: false
      t.integer :new_accepted, default: 0, null: false
      t.integer :new_rejected, default: 0, null: false
      t.integer :new_withdrawn, default: 0, null: false
      t.integer :new_initial_submissions, default: 0, null: false
      t.integer :in_process_balance, default: 0, null: false
    end
  end
end
