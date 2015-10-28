class DataMigrator::DataAvailabilityQuestionsMigrator < DataMigrator::Base

  def cleanup
    idents = ["data_availability.fully_available", "data_availability.data_location"]
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

  def initialize
    @owner_type = "TahiStandardTasks::DataAvailabilityTask"
  end

  def migrate!
    create_nested_questions
    migrate_data_fully_available_questions
    migration_data_location_questions
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: @owner_type, owner_id: nil }
    ).joins(:nested_question).destroy_all
  end

  private

  def create_nested_questions
    @nested_data_fully_available_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: @owner_type,
      text: "Do the authors confirm that all the data underlying the findings described in their manuscript are fully available without restriction?",
      ident: "data_fully_available",
      value_type: "boolean",
      position: 1
    ).first_or_create!

    @nested_data_location_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: @owner_type,
      text: "Please describe where your data may be found, writing in full sentences.",
      value_type: "text",
      ident: "data_location",
      position: 2
    ).first_or_create!
  end

  def migrate_data_fully_available_questions
    count = old_fully_available_questions.count
    from = "data_availability.fully_available"
    to = @nested_data_fully_available_question.ident

    migrating(count: count, from: from, to: to) do
      old_fully_available_questions.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_data_fully_available_question.id,
          value_type: @nested_data_fully_available_question.value_type,
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

  def migration_data_location_questions
    count = old_data_location_questions.count
    from = "data_availability.data_location"
    to = @nested_data_location_question.ident

    migrating(count: count, from: from, to: to) do
      old_data_location_questions.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_data_location_question.id,
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

  def old_fully_available_questions
    Question.where(ident: "data_availability.fully_available")
  end

  def old_data_location_questions
    Question.where(ident: "data_availability.data_location")
  end

  def verify_counts
    verify_count(
      expected: old_fully_available_questions.count,
      actual: @nested_data_fully_available_question.nested_question_answers.count,
      ident: @nested_data_fully_available_question.ident
    )

    verify_count(
      expected: old_data_location_questions.count,
      actual: @nested_data_location_question.nested_question_answers.count,
      ident: @nested_data_location_question.ident
    )
  end

  def verify_count(expected:, actual:, ident:)
    if actual != expected
      raise "Count mismatch on #{ident} NestedQuestionAnswer for #{@owner_type}. Expected: #{expected} Got: #{actual}"
    end
  end
end
