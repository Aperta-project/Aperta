require_relative "./support/card_migrator"

namespace "card_config" do
  desc "Convert NestedQuestionAnswers to Answers and associate cards to Answerables"
  task convert_nested_questions: [:environment, :add_papers_to_reviewer_reports] do
    count = Answer.count
    raise "Expected Answer to be empty, but it has #{count} rows!" unless count.zero?
    puts "------------------- Convert Nested Questions Answers Start ----------------------------"

    # To avoid id collision on the ember side, where we are making Answer look
    # like NestedQuestionAnswer, do not reuse ids.
    start = NestedQuestionAnswer.pluck(:id).max + 1
    $stderr.puts("Starting Answer.id sequence at #{start}")
    ActiveRecord::Base.connection.execute("ALTER SEQUENCE answers_id_seq RESTART WITH #{start}")

    Card.all.pluck(:name).each do |name|
      puts "+++ converting nested question answers for #{name}"
      CardConfig::CardMigrator.new(name).call
    end
    $stderr.puts("Created #{Answer.count} Answers (c.f. #{NestedQuestionAnswer.count} NestedQuestionAnswers)")
    Answer.joins(:card_content).pluck(:ident).uniq.each do |ident|
      c1 = Answer.joins(:card_content).where('card_contents.ident' => ident).count
      c2 = NestedQuestionAnswer.joins(:nested_question).where('nested_questions.ident' => ident).count
      $stderr.puts("  for #{ident}: #{c1} Answers (c.f. #{c2} NestedQuestionAnswers)")
      next if c1 == c2

      raise "Expected to create a new Answer for every NestedQuestionAnswer for #{ident}"
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
