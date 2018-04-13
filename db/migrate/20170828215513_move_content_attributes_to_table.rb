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

class MoveContentAttributesToTable < ActiveRecord::Migration
  def copy_sql(type, name)
    <<-SQL
      insert into
        content_attributes (card_content_id, name, value_type, #{type}_value, created_at, updated_at)
        select card_contents.id, '#{name}', '#{type}', card_contents.#{name}, card_contents.created_at, card_contents.updated_at
        from card_contents
        where card_contents.#{name} is not null
    SQL
  end

  def up
    create_table :content_attributes, force: true do |t|
      t.belongs_to :card_content
      t.string     :name, index: true
      t.string     :value_type, index: true
      t.boolean    :boolean_value, default: nil
      t.integer    :integer_value, default: nil
      t.string     :string_value, default: nil
      t.jsonb      :json_value, default: nil
      t.timestamps null: false
    end

    Attributable::CONTENT_ATTRIBUTES.each do |type, columns|
      columns.each do |column|
        execute copy_sql(type, column)
        execute "alter table card_contents drop column #{column}"
      end
    end

    execute "alter table card_contents drop column placeholder"
  end

  def down
    drop_table :content_attributes
  end
end
