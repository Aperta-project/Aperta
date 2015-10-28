class DataMigrator::ReviewerReportQuestionsMigrator < DataMigrator::Base
  TASK_OWNER_TYPE = "TahiStandardTasks::ReviewerReportTask"

  IDENTS = {
    ignored: %w(
      reviewer_report.intelligible
      reviewer_report.intelligible.explanation
    ),
    old: {
      COMPETING_INTERESTS_IDENT: "reviewer_report.competing_interests",
      SUPPORT_CONCLUSIONS_IDENT: "reviewer_report.support_conclusions",
      SUPPORT_CONCLUSIONS_EXPLANATION_IDENT: "reviewer_report.support_conclusions.explanation",
      STATISTICAL_ANALYSIS_IDENT: "reviewer_report.statistical_analysis",
      STATISTICAL_ANALYSIS_EXPLANATION_IDENT: "reviewer_report.statistical_analysis.explanation",
      STANDARDS_IDENT: "reviewer_report.standards",
      STANDARDS_EXPLANATION_IDENT: "reviewer_report.standards.explanation",
      ADDITIONAL_COMMENTS_IDENT: "reviewer_report.additional_comments",
      IDENTITY_IDENT: "reviewer_report.identity"
    },

    new: {
      COMPETING_INTERESTS_IDENT: "competing_interests",
      SUPPORT_CONCLUSIONS_IDENT: "support_conclusions",
      SUPPORT_CONCLUSIONS_EXPLANATION_IDENT: "explanation",
      STATISTICAL_ANALYSIS_IDENT: "statistical_analysis",
      STATISTICAL_ANALYSIS_EXPLANATION_IDENT: "explanation",
      STANDARDS_IDENT: "standards",
      STANDARDS_EXPLANATION_IDENT: "explanation",
      ADDITIONAL_COMMENTS_IDENT: "additional_comments",
      IDENTITY_IDENT: "identity"
    }
  }


  def initialize
    @subtract_from_expected_count = 0
  end

  def cleanup
    idents = IDENTS[:old].values
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
    migrate_reviewer_report_questions
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: [TASK_OWNER_TYPE], owner_id: nil }
    ).joins(:nested_question).destroy_all
  end

  private

  def create_nested_questions
    questions = []
    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "competing_interests",
      value_type: "text",
      text: "Do you have any potential or perceived competing interests that may influence your review?",
      position: 1
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "support_conclusions",
      value_type: "boolean",
      text: "Is the manuscript technically sound, and do the data support the conclusions?",
      position: 2,
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: TASK_OWNER_TYPE,
          ident: "explanation",
          value_type: "text",
          text: "Explanation",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "statistical_analysis",
      value_type: "boolean",
      text: "Has the statistical analysis been performed appropriately and rigorously?",
      position: 3,
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: TASK_OWNER_TYPE,
          ident: "explanation",
          value_type: "text",
          text: "Statistical Analysis Explanation",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "standards",
      value_type: "boolean",
      text: "Does the manuscript adhere to standards in this field for data availability?",
      position: 4,
      children: [
        NestedQuestion.new(
          owner_id: nil,
          owner_type: TASK_OWNER_TYPE,
          ident: "explanation",
          value_type: "text",
          text: "Standards Explanation",
          position: 1
        )
      ]
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "additional_comments",
      value_type: "text",
      text: "(Optional) Please offer any additional comments to the author.",
      position: 6
    )

    questions << NestedQuestion.new(
      owner_id: nil,
      owner_type: TASK_OWNER_TYPE,
      ident: "identity",
      value_type: "text",
      text: "(Optional) If you'd like your identity to be revealed to the authors, please include your name here.",
      position: 7
    )

    questions.each do |q|
      unless NestedQuestion.where(owner_id: nil, owner_type: TASK_OWNER_TYPE, ident: q.ident).exists?
        q.save!
      end
    end
  end

  def migrate_reviewer_report_questions
    IDENTS[:old].each_pair do |key, old_ident|
      new_ident = IDENTS[:new][key]
      old_questions = Question.where(ident: old_ident)
      migrating(count: old_questions.count, from: old_ident, to: new_ident) do
        old_questions.each do |old_question|
          if old_question.task.nil?
            puts
            puts
            puts "    #{yellow('Skipping')} because corresponding task does not exist for #{old_question.inspect}"
            puts
            @subtract_from_expected_count += 1
            next
          end

          nested_question = NestedQuestion.where(owner_type: TASK_OWNER_TYPE, owner_id: nil, ident: new_ident).first!

          case nested_question.value_type
          when "boolean"
            NestedQuestionAnswer.create!(
              nested_question_id: nested_question.id,
              value_type: nested_question.value_type,
              owner_id: old_question.task.id,
              owner_type: old_question.task.class.base_class.sti_name,
              value: (old_question.answer == "Yes" || old_question.answer.eql?(true)),
              decision_id: old_question.decision_id,
              created_at: old_question.created_at,
              updated_at: old_question.updated_at
            )
          else
            NestedQuestionAnswer.create!(
              nested_question_id: nested_question.id,
              value_type: nested_question.value_type,
              owner_id: old_question.task.id,
              owner_type: old_question.task.class.base_class.sti_name,
              value: old_question.answer,
              decision_id: old_question.decision_id,
              created_at: old_question.created_at,
              updated_at: old_question.updated_at
            )
          end

        end
      end
    end
  end

  def verify_counts
    expected_questions = Question.where("ident LIKE 'reviewer_report.%' AND ident NOT IN (?)", IDENTS[:ignored])
    verify_count(
      expected: expected_questions.count - @subtract_from_expected_count,
      actual: NestedQuestionAnswer.includes(:nested_question).where(nested_questions: { owner_type: TASK_OWNER_TYPE, owner_id: nil }).count
    )
  end

  def verify_count(expected:, actual:)
    if actual != expected
      fail "Count mismatch on NestedQuestionAnswer for #{TASK_OWNER_TYPE}. Expected: #{expected} Got: #{actual}"
    end
  end
end
