class MoveCardAttributesToTable < ActiveRecord::Migration
  def copy_sql(type, name)
    <<-SQL
      insert into
        card_attributes (card_content_id, name, value_type, #{type}_value, created_at, updated_at)
        select card_contents.id, '#{name}', '#{type}', card_contents.#{name}, card_contents.created_at, card_contents.updated_at
        from card_contents
        where card_contents.#{name} is not null
    SQL
  end

  def up
    create_table :card_attributes, force: true do |t|
      t.belongs_to :card_content
      t.string     :name, index: true
      t.string     :value_type, index: true
      t.boolean    :boolean_value, default: nil
      t.integer    :integer_value, default: nil
      t.string     :string_value, default: nil
      t.jsonb      :json_value, default: nil
      t.timestamps null: false
    end

    [
      ['boolean', %w[allow_annotations allow_file_captions allow_multiple_uploads required_field]],
      ['string',  %w[condition content_type default_answer_value editor_style error_message
                     instruction_text label text value_type visible_with_parent_answer]],
      ['json',    %w[possible_values]]
    ].each do |type, columns|
      columns.each { |column| execute copy_sql(type, column) }
    end
  end

  def down
    drop_table :card_attributes
  end
end
