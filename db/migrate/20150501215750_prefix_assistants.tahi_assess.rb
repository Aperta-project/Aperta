# This migration comes from tahi_assess (originally 20150408215843)
class PrefixAssistants < ActiveRecord::Migration
  def change
    rename_table :assess_assistants, :tahi_assess_assistants
  end
end
