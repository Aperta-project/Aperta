class RequireFieldsOnVersionedText < ActiveRecord::Migration
  def change
    change_column_null :versioned_texts, :paper_id, false
    change_column_null :versioned_texts, :minor_version, false
    change_column_default :versioned_texts, :minor_version, nil
    change_column_null :versioned_texts, :major_version, false
    change_column_default :versioned_texts, :major_version, nil
  end
end
