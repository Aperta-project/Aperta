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
