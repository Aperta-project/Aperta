namespace :data do
  namespace :migrate do
    namespace :tasks do
      desc 'Sets the PRQ Tasks titles to Additional Information'
      task set_title_to_additional_information: :environment do
        type = 'TahiStandardTasks::PublishingRelatedQuestionsTask'
        Task.where(type: type).update_all(title: 'Additional Information')
      end
    end
  end
end
