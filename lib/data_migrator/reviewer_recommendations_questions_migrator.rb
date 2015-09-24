class DataMigrator::ReviewerRecommendationsQuestionsMigrator < DataMigrator::Base
  REVIEWER_RECOMMENDATION = "TahiStandardTasks::ReviewerRecommendation"

  def cleanup
    puts yellow("Cleanup must be done in a database migration to drop the recommend_or_oppose and reason columns.")
    idents = []
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

    migrate_recommend_or_oppose_question
    migrate_reason_question
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: REVIEWER_RECOMMENDATION, owner_id: nil }
    ).joins(:nested_question).destroy_all
  end

  private

  def migrate_recommend_or_oppose_question
    count = old_recommendations.count
    from = "recommendOrOppose"
    to = @nested_recommend_or_oppose_question

    migrating(count: count, from: from, to: to) do
      old_recommendations.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_recommend_or_oppose_question.id,
          value_type: "text",
          owner_id: old_question.id,
          owner_type: TahiStandardTasks::ReviewerRecommendation.base_class.sti_name,
          value: old_question.recommend_or_oppose,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def old_recommendations
    TahiStandardTasks::ReviewerRecommendation.all
  end

  def migrate_reason_question
    count = old_reasons.count
    from = "reason"
    to = @nested_reason_question

    migrating(count: count, from: from, to: to) do
      old_reasons.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_reason_question.id,
          value_type: "text",
          owner_id: old_question.id,
          owner_type: TahiStandardTasks::ReviewerRecommendation.base_class.sti_name,
          value: old_question.reason,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def old_reasons
    TahiStandardTasks::ReviewerRecommendation.where("reason is not null" )
  end

  def create_nested_questions
    @nested_recommend_or_oppose_question= NestedQuestion.where(
      owner_id: nil,
      owner_type: REVIEWER_RECOMMENDATION,
      ident: "recommend_or_oppose",
      value_type: "text",
      text: "Are you recommending or opposing this reviewer? (required)"
    ).first_or_create!

    @nested_reason_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: REVIEWER_RECOMMENDATION,
      ident: "reason",
      value_type: "text",
      text: "Optional: reason for recommending or opposing this reviewer"
    ).first_or_create!
  end

  def verify_counts
    verify_count(
      expected: old_recommendations.count,
      actual: @nested_recommend_or_oppose_question.nested_question_answers.count,
      ident: "recommend_or_oppose"
    )
    verify_count(
      expected: old_reasons.count,
      actual: @nested_reason_question.nested_question_answers.count,
      ident: "reason"
    )
  end

  def verify_count(expected:, actual:, ident:)
    if actual != expected
      raise "Count mismatch on #{ident} NestedQuestionAnswer for #{REVIEWER_RECOMMENDATIONS_TASK}. Expected: #{expected} Got: #{actual}"
    end
  end
end
