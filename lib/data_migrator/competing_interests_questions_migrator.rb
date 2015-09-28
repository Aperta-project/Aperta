class DataMigrator::CompetingInterestsQuestionsMigrator < DataMigrator::Base
  COMPETING_INTERESTS_TASK = "TahiStandardTasks::CompetingInterestsTask"

  def cleanup
    idents = ["competing_interest.any", "competing_interest.competing_interests"]
    puts
    puts yellow("Removing all Question(s) with idents: #{idents.join(', ')}")
    answer = ask "Are you sure you want to delete these Question(s)? [y/N]"
    loop do
      if answer =~ /n/i
        return
      elsif answer =~ /y/i
        break
      else
        answer = ask "Please answer y, n, or Ctrl-C to cancel."
      end
    end

    Question.where(ident: idents).destroy_all
  end

  def migrate!
    create_nested_questions
    migrate_competing_interests_any
    migrate_competing_interests_statement
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: COMPETING_INTERESTS_TASK, owner_id:nil },
    ).joins(:nested_question).destroy_all
  end

  private

  def create_nested_questions
    @nested_competing_interests_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: COMPETING_INTERESTS_TASK,
      text: "Do any authors of this manuscript have competing interests (as described in the <a target='_blank' href='http://www.plosbiology.org/static/policies#competing'>PLOS Policy on Declaration and Evaluation of Competing Interests</a>)?",
      value_type: "boolean",
      ident: "competing_interests"
    ).first_or_create!

    @nested_competing_interests_statement_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: COMPETING_INTERESTS_TASK,
      text: "Please provide details about any and all competing interests in the box below. Your response should begin with this statement: \"I have read the journal's policy and the authors of this manuscript have the following competing interests.\"",
      value_type: "text",
      ident: "statement",
      parent_id: @nested_competing_interests_question.id
    ).first_or_create!
  end

  def migrate_competing_interests_any
    count = old_competing_interests_any_questions.count
    from = "competing_interest.any"
    to = @nested_competing_interests_question.ident

    migrating(count: count, from: from, to: to) do
      old_competing_interests_any_questions.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_competing_interests_question.id,
          value_type: "boolean",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer == "Yes"),
          decision_id: old_question.decision_id,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def migrate_competing_interests_statement
    count = old_competing_interests_statement_questions.count
    from = "competing_interest.competing_interests"
    to = @nested_competing_interests_statement_question.ident

    migrating(count: count, from: from, to: to) do
      old_competing_interests_statement_questions.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_competing_interests_statement_question.id,
          value_type: "text",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question ? old_question.answer : nil),
          decision_id: old_question.decision_id,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def old_competing_interests_any_questions
    Question.where(ident: "competing_interests.any")
  end

  def old_competing_interests_statement_questions
    Question.where(ident: "competing_interests.competing_interests")
  end

  def verify_counts
    verify_count(
      expected: old_competing_interests_any_questions.count,
      actual: @nested_competing_interests_question.nested_question_answers.count,
      ident: "competing_interests"
    )

    verify_count(
      expected: old_competing_interests_statement_questions.count,
      actual: @nested_competing_interests_statement_question.nested_question_answers.count,
      ident: "statement"
    )
  end

  def verify_count(expected:, actual:, ident:)
    if actual != expected
      raise "Count mismatch on #{ident} NestedQuestionAnswer for #{COMPETING_INTERESTS_TASK}. Expected: #{expected} Got: #{actual}"
    end
  end
end
