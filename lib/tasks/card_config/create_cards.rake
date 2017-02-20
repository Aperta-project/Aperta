require_relative "./support/card_creator"

namespace "card_config" do
  desc "Convert NestedQuestionAnswers to Answers and associate cards to Answerables"
  task convert_nested_questions: [:environment, :clean, :add_papers_to_reviewer_reports] do
    puts "------------------- Convert Nested Questions Answers Start ----------------------------"
    answerables = ObjectSpace.each_object(Class).select { |c| c.included_modules.include? Answerable } - [Task]
    answerables.each do |klass|
      puts "+++ converting nested question answers for #{klass.name}"
      CardConfig::CardCreator.new(owner_klass: klass).call
    end
    puts "------------------- Convert Nested Questions Answers End ----------------------------"
  end

  task clean: :environment do
    # acts as paranoid cleanup for new models
    Answer.delete_all!
  end

  task :add_papers_to_reviewer_reports do
    # existing answer for reviewer reports don't necessarily have their papers set.
    # we want to normalize this.
    puts "Types of owners whose answers don't have paper_ids: #{NestedQuestionAnswer.where(paper_id: nil).group(:owner_type).count}"
    ReviewerReport.all.each do |report|
      report.nested_question_answers.update_all(paper_id: report.paper.id)
    end
    puts "After update: #{NestedQuestionAnswer.where(paper_id: nil).count} answers with no paper id"
  end
end
