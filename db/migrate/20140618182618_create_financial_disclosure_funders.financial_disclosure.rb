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

# This migration comes from financial_disclosure (originally 20140618180941)
class CreateFinancialDisclosureFunders < ActiveRecord::Migration
  def change
    create_table :financial_disclosure_funders do |t|
      t.string :name
      t.string :grant_number
      t.string :website
      t.boolean :funder_had_influence
      t.text :funder_influence_description
      t.references :task, index: true
      t.timestamps
    end

    create_table :financial_disclosure_funded_authors do |t|
      t.references :author, index: true
      t.references :funder, index: true
    end

    add_index :financial_disclosure_funded_authors, [:author_id, :funder_id],
      unique: true, name: "funded_authors_unique_index"
  end
end
