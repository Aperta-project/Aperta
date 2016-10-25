class CreateOrcidAccounts < ActiveRecord::Migration
  def change
    create_table    :orcid_accounts do |t|
      t.belongs_to  :user, index: true

      t.string      :access_token
      t.string      :refresh_token
      t.string      :identifier
      t.datetime    :expires_at
      t.string      :name
      t.string      :scope

      t.jsonb       :authorization_code_response
      t.text        :profile_xml
      t.datetime    :profile_xml_updated_at

      t.timestamps  null: false
    end
  end
end
