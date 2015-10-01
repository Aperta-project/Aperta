class DataMigrator::EthicsQuestionsMigrator < DataMigrator::Base
  OWNER_TYPE = "TahiStandardTasks::EthicsTask"

  def cleanup
    idents = ["ethics.human_subjects", "ethics.human_subjects.participants", "ethics.animal_subjects", "ethics.animal_subjects.field_permit"]
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
    migrate_human_subjects_questions
    migrate_participants_questions
    migrate_animal_subjects_questions
    migrate_field_permit_questions
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: OWNER_TYPE, owner_id: nil }
    ).joins(:nested_question).destroy_all
  end

  private

  def create_nested_questions
    @nested_human_subjects_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: OWNER_TYPE,
      text: "Does your study involve Human Subject Research (human participants and/or tissue)?",
      ident: "human_subjects",
      value_type: "boolean"
    ).first_or_create!

    @nested_participants_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: OWNER_TYPE,
      text: "Please enter the name of the IRB or Ethics Committee that approved this study in the space below. Include the approval number and/or a statement indicating approval of this research.",
      value_type: "text",
      ident: "participants",
      parent: @nested_human_subjects_question
    ).first_or_create!

    @nested_animal_subjects_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: OWNER_TYPE,
      text: "Does your study involve Animal Research (vertebrate animals, embryos or tissues)?",
      ident: "animal_subjects",
      value_type: "boolean"
    ).first_or_create!

    @nested_field_permit_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: OWNER_TYPE,
      text: "Please enter your statement below:",
      value_type: "text",
      ident: "field_permit",
      parent: @nested_animal_subjects_question
    ).first_or_create!
  end

  def migrate_human_subjects_questions
    count = old_human_subjects_questions.count
    from = "ethics.human_subjects"
    to = @nested_human_subjects_question.ident

    migrating(count: count, from: from, to: to) do
      old_human_subjects_questions.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_human_subjects_question.id,
          value_type: @nested_human_subjects_question.value_type,
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

  def migrate_participants_questions
    count = old_participants_questions.count
    from = "ethics.human_subjects.participants"
    to = @nested_participants_question.ident

    migrating(count: count, from: from, to: to) do
      old_participants_questions.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_participants_question.id,
          value_type: @nested_participants_question.value_type,
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

  def migrate_animal_subjects_questions
    count = old_animal_subjects_questions.count
    from = "ethics.animal_subjects"
    to = @nested_animal_subjects_question.ident

    migrating(count: count, from: from, to: to) do
      old_animal_subjects_questions.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_animal_subjects_question.id,
          value_type: @nested_animal_subjects_question.value_type,
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

  def migrate_field_permit_questions
    count = old_field_permit_questions.count
    from = "ethics.human_subjects.field_permit"
    to = @nested_field_permit_question.ident

    migrating(count: count, from: from, to: to) do
      old_field_permit_questions.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_field_permit_question.id,
          value_type: @nested_field_permit_question.value_type,
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

  def old_human_subjects_questions
    Question.where(ident: "ethics.human_subjects")
  end

  def old_participants_questions
    Question.where(ident: "ethics.human_subjects.participants")
  end

  def old_animal_subjects_questions
    Question.where(ident: "ethics.animal_subjects")
  end

  def old_field_permit_questions
    Question.where(ident: "ethics.animal_subjects.field_permit")
  end

  def verify_counts
    verify_count(
      expected: old_human_subjects_questions.count,
      actual: @nested_human_subjects_question.nested_question_answers.count,
      ident: @nested_human_subjects_question.ident
    )

    verify_count(
      expected: old_participants_questions.count,
      actual: @nested_participants_question.nested_question_answers.count,
      ident: @nested_participants_question.ident
    )

    verify_count(
      expected: old_animal_subjects_questions.count,
      actual: @nested_animal_subjects_question.nested_question_answers.count,
      ident:  @nested_animal_subjects_question.ident
    )

    verify_count(
      expected: old_field_permit_questions.count,
      actual: @nested_field_permit_question.nested_question_answers.count,
      ident: @nested_field_permit_question.ident
    )
  end

  def verify_count(expected:, actual:, ident:)
    if actual != expected
      raise "Count mismatch on #{ident} NestedQuestionAnswer for #{OWNER_TYPE}. Expected: #{expected} Got: #{actual}"
    end
  end
end
