namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7457: Finish removal of PaperAdminTasks

      * Remove JournalTaskTypes referring to this type
      * Remove existing TaskTemplates of this type
      * Remove existing Tasks of this type
    DESC
    task finish_removal_of_paper_admin_tasks: :environment do
      # Remove any remaining data on templates
      templates = TaskTemplate.where(title: 'Assign Admin').destroy_all
      JournalTaskType.where(id: templates.map(&:journal_task_type_id).uniq).destroy_all

      unless TahiStandardTasks.const_defined? :PaperAdminTask
        class TahiStandardTasks::PaperAdminTask < Task
        end
      end

      # Remove any remaining data on specific tasks
      tasks = Task.where(type: 'TahiStandardTasks::PaperAdminTask')
      tasks.each do |task|
        task.permission_requirements.destroy_all
        # participations are a subset of assignments which are dependent on destroy
        # attachments also get cleaned up when tasks are destroyed
        task.destroy
      end
    end
  end
end
