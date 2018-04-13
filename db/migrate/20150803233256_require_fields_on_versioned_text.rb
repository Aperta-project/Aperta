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

class RequireFieldsOnVersionedText < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        # delete orphan versioned_texts
        execute "DELETE FROM versioned_texts where paper_id IS NULL;"
      end
    end

    change_column_null :versioned_texts, :paper_id, false
    change_column_null :versioned_texts, :minor_version, false
    change_column_default :versioned_texts, :minor_version, nil
    change_column_null :versioned_texts, :major_version, false
    change_column_default :versioned_texts, :major_version, nil

    reversible do |dir|
      dir.up do
        # ensure all papers have a latest_version
        execute("SELECT id FROM papers WHERE id NOT IN (SELECT paper_id FROM versioned_texts WHERE paper_id IS NOT NULL);").each do |row|
          execute("INSERT INTO versioned_texts (major_version, minor_version, text, paper_id) VALUES (0, 0, '', #{row['id']});")
        end
      end
    end
  end
end
