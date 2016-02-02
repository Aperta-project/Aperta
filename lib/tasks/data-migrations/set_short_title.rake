namespace :data do
  namespace :migrate do
    namespace :nested_questions do
      desc "Sets the paper short title *answer* to be the paper's short title"
      task set_short_title: :environment do
        Paper.all.each do |paper|
          task = paper.tasks_for_type(
            TahiStandardTasks::PublishingRelatedQuestionsTask).first
          next unless task
          question = task.nested_questions.find_by(
            ident: 'publishing_related_questions--short_title')
          answer = task.find_or_build_answer_for(
            nested_question: question)
          answer.value = paper.read_attribute(:short_title) || ''
          answer.save!
        end
      end
    end
  end
end
