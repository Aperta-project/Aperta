require_relative "./support/card_migrator"

namespace "card_config" do
  desc "Convert NestedQuestionAnswers to Answers and associate cards to Answerables"
  task convert_nested_questions: [:environment, :add_papers_to_reviewer_reports] do
    count = Answer.count
    raise "Expected Answer to be empty, but it has #{count} rows!" unless count.zero?
    puts "------------------- Convert Nested Questions Answers Start ----------------------------"
    answerables = ObjectSpace.each_object(Class).select { |c| c.included_modules.include? Answerable } - [Task]
    answerables.each do |klass|
      puts "+++ converting nested question answers for #{klass.name}"
      CardConfig::CardMigrator.new(owner_klass: klass).call
    end
    count = Answer.count
    nqa_count = NestedQuestionAnswer.count
    $stderr.puts("Created #{count} Answers (c.f. #{nqa_count} NestedQuestionAnswers)")
    unless count == nqa_count
      idents = Answer.joins(:card_content).pluck(:ident).uniq
      nqa_idents = NestedQuestionAnswer.joins(:nested_question).all.pluck(:ident).uniq
      missing = (nqa_idents - idents)
      $stderr.puts("Missing idents: #{missing}")
      raise 'Expected to create a new Answer for every NestedQuestionAnswer'
    end
    puts "------------------- Convert Nested Questions Answers End ----------------------------"
  end

  task :add_papers_to_reviewer_reports do
    # existing answer for reviewer reports don't necessarily have their papers set.
    # we want to normalize this.
    puts "Types of owners whose answers don't have paper_ids: #{NestedQuestionAnswer.where(paper_id: nil).group(:owner_type).count}"

    # TODO: what should we do with these orphans?
    # Delete them for now
    bad_ids = ReviewerReport.pluck(:task_id).select { |task_id| !Task.exists?(task_id) }
    ReviewerReport.where(task_id: bad_ids).destroy_all

    ReviewerReport.all.each do |report|
      report.nested_question_answers.update_all(paper_id: report.paper.id)
    end
    puts "After update: #{NestedQuestionAnswer.where(paper_id: nil).count} answers with no paper id"
  end
end
