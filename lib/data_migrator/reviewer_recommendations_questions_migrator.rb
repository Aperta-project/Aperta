class DataMigrator::ReviewerRecommendationsQuestionsMigrator < DataMigrator::Base
  
  IDENTS = {
    RECOMMEND_OR_OPPOSE: "recommend_or_oppose",
    REASON: "reason"
  }

  def initialize
    @subtract_from_expected_count = 0
    @owner_type = "TahiStandardTasks::ReviewerRecommendation"
  end

  def cleanup
    # no-op, no previous questions
  end

  def migrate!
    create_nested_questions
    migrate_answers
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: [@owner_type], owner_id: nil }
    ).joins(:nested_question).destroy_all
  end

  private

  def create_nested_questions
    questions = []

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: @owner_type,
      ident: IDENTS[:RECOMMEND_OR_OPPOSE],
      value_type: "boolean",
      text: "Recommend or oppose",
      position: 1
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: @owner_type,
      ident: IDENTS[:REASON],
      value_type: "text",
      text: "Reason",
      position: 2
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id: nil, owner_type: @owner_type, ident: q.ident).exists?
        q.save!
      end
    end
  end

  def recommend_or_oppose_question
    NestedQuestion.where(ident: IDENTS[:RECOMMEND_OR_OPPOSE], owner_type: @owner_type, owner_id: nil).first!
  end

  def reason_question
    NestedQuestion.where(ident: IDENTS[:REASON], owner_type: @owner_type, owner_id: nil).first!
  end

  def migrate_answers
    recommendations = ::TahiStandardTasks::ReviewerRecommendation.all
    recommendations.each do |recommendation|
      if recommendation.reviewer_recommendations_task.nil?
        puts
        puts
        puts "    #{yellow('Skipping')} because corresponding reviewer_recommendations_task does not exist for #{recommendation.inspect}"
        puts
        @subtract_from_expected_count += 2
        next
      end

      recommend_or_oppose = recommendation[:recommend_or_oppose] =~ /Recommend/i ? true : false
      reason = recommendation[:reason]

      NestedQuestionAnswer.create!(
        owner: recommendation,
        nested_question: recommend_or_oppose_question,
        value_type: recommend_or_oppose_question.value_type,
        value: recommend_or_oppose
      )

      if reason.present?
        NestedQuestionAnswer.create!(
          owner: recommendation,
          nested_question: reason_question,
          value_type: reason_question.value_type,
          value: reason
        )
      else
        @subtract_from_expected_count += 1
      end
    end
  end

  def verify_counts
    number_of_fields_converted = IDENTS.length
    verify_count(
      expected: (TahiStandardTasks::ReviewerRecommendation.count * number_of_fields_converted) - @subtract_from_expected_count,
      actual: NestedQuestionAnswer.includes(:nested_question).where(nested_questions: { owner_type: @owner_type, owner_id: nil }).count
    )
  end

  def verify_count(expected:, actual:)
    if actual != expected
      raise "Count mismatch on NestedQuestionAnswer for #{@owner_type}. Expected: #{expected} Got: #{actual}"
    end
  end
end
