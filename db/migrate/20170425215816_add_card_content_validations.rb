class AddCardContentValidations < ActiveRecord::Migration
  def up
    create_table :card_content_validations do |t|
      t.string :validator
      t.string :validation_type, null: false
      t.text :error_message
      t.references :card_content, index: true

      t.timestamps
    end

    add_foreign_key :card_content_validations, :card_contents
  end

  def down
    drop_table :card_content_validations
  end
end
