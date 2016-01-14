namespace :data do
  namespace :migrate do
    namespace :nested_questions do
      desc 'Sets the paper id on all nested question answers'
      task paper_id_on_nested_question_answers: :environment do
        NestedQuestionAnswer.all.each do |answer|
          if answer.owner.respond_to?(:paper)
            answer.update(paper: answer.owner.paper)
          end
        end
      end
    end
  end
end
