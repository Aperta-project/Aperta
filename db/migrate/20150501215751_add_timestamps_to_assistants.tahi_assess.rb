# This migration comes from tahi_assess (originally 20150410185455)
class AddTimestampsToAssistants < ActiveRecord::Migration
  def change
    add_timestamps(:tahi_assess_assistants)
  end
end
