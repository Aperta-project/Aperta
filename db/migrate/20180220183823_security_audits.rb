class SecurityAudits < ActiveRecord::Migration
  def change
    create_table :security_audits, force: true do |t|
      t.belongs_to :user
      t.integer    :status
      t.string     :controller
      t.string     :action
      t.string     :format
      t.text       :path
      t.text       :params
      t.text       :key_names
      t.text       :data_types
      t.json       :payload
      t.timestamps
    end
  end
end
