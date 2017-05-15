class AddRequiredForSubmissionToCardVersions < ActiveRecord::Migration
  def change
    add_column :card_versions, :required_for_submission, :boolean, null: false, default: false
  end
end
