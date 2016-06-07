# We're going to use nil values to represent draft texts from now on.
class RemoveConstraintFromVersionedTexts < ActiveRecord::Migration
  def change
    change_column_null :versioned_texts, :major_version, true
    change_column_null :versioned_texts, :minor_version, true
  end
end
