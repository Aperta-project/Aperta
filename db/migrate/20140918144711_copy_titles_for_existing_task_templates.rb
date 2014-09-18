class CopyTitlesForExistingTaskTemplates < ActiveRecord::Migration
  def up
    TaskTemplate.where(title: nil).find_each do |template|
      template.update_attribute(:title, template.journal_task_type.try(:title))
    end
  end

  def down
  end
end
