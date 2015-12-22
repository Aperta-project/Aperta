class ConvertFlowManangerQueryRoleToOldRole < ActiveRecord::Migration
  class Flow < ActiveRecord::Base
    serialize :query, Hash
  end

  def up
    Flow.reset_column_information
    Flow.all.each do |flow|

      if flow.query.has_key?("role")
        role_name = flow.query["role"]
        flow.query = flow.query.except("role").merge("old_role" => role_name)
        flow.save!
      end
    end
  end

  def down
    Flow.reset_column_information
    Flow.all.each do |flow|

      if flow.query.has_key?("old_role")
        role_name = flow.query["old_role"]
        flow.query = flow.query.except("old_role").merge("role" => role_name)
        flow.save!
      end
    end
  end

end
