class RemoveOrcidResponsesFromOrcidAccount < ActiveRecord::Migration
  def up
    remove_column :orcid_accounts, :authorization_code_response
    remove_column :orcid_accounts, :profile_xml
    remove_column :orcid_accounts, :profile_xml_updated_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
