class AddSettingTemplateReferenceToSettings < ActiveRecord::Migration
  def change
    add_reference :settings, :setting_template, index: true, foreign_key: true
  end
end
