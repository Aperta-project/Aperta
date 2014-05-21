class AddPolymorphicToAffiliations < ActiveRecord::Migration
  def change
    rename_column :affiliations, :user_id, :affiliable_id
    add_column :affiliations, :affiliable_type, :string
    Affiliation.update_all(affiliable_type: "User")
  end
end
