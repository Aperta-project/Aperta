namespace :data do
  namespace :migrate do
    namespace :supporting_information_files do
      desc 'Sets the Task position value based on actual ordering'
      task update_task_reference: :environment do
        task_type = 'TahiStandardTasks::SupportingInformationTask'
        SupportingInformationFile.all.each do |si_file|
          task = si_file.paper.tasks.find_by(type: task_type)
          si_file.update_column(:si_task_id, task.id)
        end
      end
    end
  end
end
