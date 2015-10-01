class DataMigrator::ReportingGuidelinesQuestionsMigrator < DataMigrator::Base
  REPORTING_GUIDELINES_TASK = "TahiStandardTasks::ReportingGuidelinesTask"

  def cleanup
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

    migrate_clinical_trial_question
    migrate_systematic_reviews_question
    migrate_systematic_reviews_checklist
    migrate_meta_analyses_question
    migrate_meta_analyses_checklist

    migrate_diagnostic_studies_question
    migrate_epidemiological_studies_question
    migrate_microarray_studies_question

    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: REPORTING_GUIDELINES_TASK, owner_id: nil }
    ).joins(:nested_question).destroy_all
  end

  private

  def migrate_clinical_trial_question
    count = old_clinical_trial_question.count
    from = "reporting_guidelines.clinical_trial"
    to = @nested_clinical_trial_question

    migrating(count: count, from: from, to: to) do
      old_clinical_trial_question.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_clinical_trial_question.id,
          value_type: "boolean",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer == "true"),
          decision_id: old_question.decision_id,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def old_clinical_trial_question
    Question.where(ident: "reporting_guidelines.clinical_trial")
  end

  def migrate_systematic_reviews_question
    count = old_systematic_reviews_question.count
    from = "reporting_guidelines.systematic_reviews"
    to = @nested_systematic_reviews_question

    migrating(count: count, from: from, to: to) do
      old_systematic_reviews_question.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_systematic_reviews_question.id,
          value_type: "boolean",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer == "true"),
          decision_id: old_question.decision_id,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def old_systematic_reviews_question
    Question.where(ident: "reporting_guidelines.systematic_reviews")
  end

  def migrate_systematic_reviews_checklist
    count = old_systematic_reviews_checklist.count
    from = "reporting_guidelines.systematic_reviews.prisma_checklist"
    to = @nested_systematic_reviews_checklist

    migrating(count: count, from: from, to: to) do
      old_systematic_reviews_checklist.all.each do |old_question|
        answer = NestedQuestionAnswer.create!(
          nested_question_id: @nested_systematic_reviews_checklist.id,
          value_type: "attachment",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: old_question.question_attachment[:attachment],
          decision_id: old_question.decision_id,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
        answer.create_attachment!(old_question.question_attachment.attributes.except("id", "question_id", "question_type"))
      end
    end
  end

  def old_systematic_reviews_checklist
    Question.where(ident: "reporting_guidelines.systematic_reviews.prisma_checklist")
  end

  def migrate_meta_analyses_question
    count = old_meta_analyses_question.count
    from = "reporting_guidelines.meta_analyses"
    to = @nested_meta_analyses_question

    migrating(count: count, from: from, to: to) do
      old_meta_analyses_question.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_meta_analyses_question.id,
          value_type: "boolean",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer == "true"),
          decision_id: old_question.decision_id,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def old_meta_analyses_question
    Question.where(ident: "reporting_guidelines.meta_analyses")
  end

  def migrate_meta_analyses_checklist
    count = old_systematic_reviews_checklist.count
    from = "reporting_guidelines.meta_analyses.prisma_checklist"
    to = @nested_meta_analyses_checklist

    migrating(count: count, from: from, to: to) do
      old_meta_analyses_checklist.all.each do |old_question|
        answer = NestedQuestionAnswer.create!(
          nested_question_id: @nested_meta_analyses_checklist.id,
          value_type: "attachment",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: old_question.question_attachment[:attachment],
          decision_id: old_question.decision_id,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
        answer.create_attachment!(old_question.question_attachment.attributes.except("id", "question_id", "question_type"))
      end
    end
  end

  def old_meta_analyses_checklist
    Question.where(ident: "reporting_guidelines.meta_analyses.prisma_checklist")
  end

  def migrate_diagnostic_studies_question
    count = old_diagnostic_studies_question.count
    from = "reporting_guidelines.diagnostic_studies"
    to = @nested_diagnostic_studies_question

    migrating(count: count, from: from, to: to) do
      old_diagnostic_studies_question.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_diagnostic_studies_question.id,
          value_type: "boolean",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer == "true"),
          decision_id: old_question.decision_id,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def old_diagnostic_studies_question
    Question.where(ident: "reporting_guidelines.diagnostic_studies")
  end

  def migrate_epidemiological_studies_question
    count = old_epidemiological_studies_question.count
    from = "reporting_guidelines.epidemiological_studies"
    to = @nested_epidemiological_studies_question

    migrating(count: count, from: from, to: to) do
      old_epidemiological_studies_question.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_epidemiological_studies_question.id,
          value_type: "boolean",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer == "true"),
          decision_id: old_question.decision_id,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def old_epidemiological_studies_question
    Question.where(ident: "reporting_guidelines.epidemiological_studies")
  end

  def migrate_microarray_studies_question
    count = old_microarray_studies_question.count
    from = "reporting_guidelines.microarray_studies"
    to = @nested_microarray_studies_question

    migrating(count: count, from: from, to: to) do
      old_microarray_studies_question.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_microarray_studies_question.id,
          value_type: "boolean",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer == "true"),
          decision_id: old_question.decision_id,
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def old_microarray_studies_question
    Question.where(ident: "reporting_guidelines.microarray_studies")
  end

  def create_nested_questions
    @nested_clinical_trial_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: REPORTING_GUIDELINES_TASK,
      text: "Clinical Trial",
      value_type: "boolean",
      ident: "clinical_trial"
    ).first_or_create!

    @nested_systematic_reviews_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: REPORTING_GUIDELINES_TASK,
      text: "Systematic Reviews",
      value_type: "boolean",
      ident: "systematic_reviews"
    ).first_or_create!

    @nested_systematic_reviews_checklist = NestedQuestion.where(
      owner_id: nil,
      owner_type: REPORTING_GUIDELINES_TASK,
      text: "Provide a completed PRISMA checklist as supporting information.  You can <a href='http://www.prisma-statement.org/'>download it here</a>.",
      value_type: "attachment",
      ident: "checklist",
      parent_id: @nested_systematic_reviews_question
    ).first_or_create!

    @nested_meta_analyses_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: REPORTING_GUIDELINES_TASK,
      text: "Meta-analyses",
      value_type: "boolean",
      ident: "meta_analyses"
    ).first_or_create!

    @nested_meta_analyses_checklist = NestedQuestion.where(
      owner_id: nil,
      owner_type: REPORTING_GUIDELINES_TASK,
      text: "Provide a completed PRISMA checklist as supporting information.  You can <a href='http://www.prisma-statement.org/'>download it here</a>.",
      value_type: "attachment",
      ident: "checklist",
      parent_id: @nested_meta_analyses_question
    ).first_or_create!

    @nested_diagnostic_studies_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: REPORTING_GUIDELINES_TASK,
      text: "Diagnostic studies",
      value_type: "boolean",
      ident: "diagnostic_studies"
    ).first_or_create!

    @nested_epidemiological_studies_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: REPORTING_GUIDELINES_TASK,
      text: "Epidemiological studies",
      value_type: "boolean",
      ident: "epidemiological_studies"
    ).first_or_create!

    @nested_microarray_studies_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: REPORTING_GUIDELINES_TASK,
      text: "Microarray studies",
      value_type: "boolean",
      ident: "microarray_studies"
    ).first_or_create!
  end

  def verify_counts
    verify_count(
      expected: old_clinical_trial_question.count,
      actual: @nested_clinical_trial_question.nested_question_answers.count,
      ident: "clinical_trial"
    )
    verify_count(
      expected: old_systematic_reviews_question.count,
      actual: @nested_systematic_reviews_question.nested_question_answers.count,
      ident: "systematic_reviews"
    )
    verify_count(
      expected: old_systematic_reviews_checklist.count,
      actual: @nested_systematic_reviews_checklist.nested_question_answers.count,
      ident: "systematic_reviews.checklist"
    )
    verify_count(
      expected: old_meta_analyses_question.count,
      actual: @nested_meta_analyses_question.nested_question_answers.count,
      ident: "meta_analyses"
    )
    verify_count(
      expected: old_meta_analyses_checklist.count,
      actual: @nested_meta_analyses_checklist.nested_question_answers.count,
      ident: "meta_analyses.checklist"
    )
    verify_count(
      expected: old_diagnostic_studies_question.count,
      actual: @nested_diagnostic_studies_question.nested_question_answers.count,
      ident: "diagnostic_studies"
    )
    verify_count(
      expected: old_epidemiological_studies_question.count,
      actual: @nested_epidemiological_studies_question.nested_question_answers.count,
      ident: "epidemiological_studies"
    )
    verify_count(
      expected: old_microarray_studies_question.count,
      actual: @nested_microarray_studies_question.nested_question_answers.count,
      ident: "microarray_studies"
    )

  end

  def verify_count(expected:, actual:, ident:)
    if actual != expected
      raise "Count mismatch on #{ident} NestedQuestionAnswer for #{REPORTING_GUIDELINES_TASK}. Expected: #{expected} Got: #{actual}"
    end
  end
end
