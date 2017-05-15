namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7457: Finish removal of PaperAdminTasks

      * Remove JournalTaskTypes referring to this type
      * Remove existing TaskTemplates of this type
      * Remove existing Tasks of this type
      * Remove permission requirements for this type
      * Remove permissions for this type
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
      task_klass_str = 'TahiStandardTasks::PaperAdminTask'
      Task.where(type: task_klass_str).destroy_all

      # Remove any permissions that exist on this no longer existent task
      Permission.where(applies_to: task_klass_str).destroy_all
    end
  end
end
