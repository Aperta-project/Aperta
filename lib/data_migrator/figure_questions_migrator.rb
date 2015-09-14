class DataMigrator::FigureQuestionsMigrator < DataMigrator::Base
  OWNER_TYPE = "TahiStandardTasks::FigureTask"

  OLD_FIGURES_COMPLIES_IDENT = "figures.complies"
  NEW_FIGURES_COMPLIES_IDENT = "figure_complies"

  def initialize
    @subtract_from_expected_count = 0
  end

  def cleanup
    idents = [OLD_FIGURES_COMPLIES_IDENT]
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
    migrate_figure_complies_questions
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: OWNER_TYPE, owner_id: nil },
    ).joins(:nested_question).destroy_all
  end

  private

  def create_nested_questions
    @nested_figure_complies_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: OWNER_TYPE,
      text: "Yes - I confirm our figures comply with the guidelines.",
      ident: NEW_FIGURES_COMPLIES_IDENT,
      value_type: "boolean"
    ).first_or_create!
  end

  def migrate_figure_complies_questions
    count = old_figure_complies_questions.count
    from = OLD_FIGURES_COMPLIES_IDENT
    to = @nested_figure_complies_question.ident

    migrating(count: count, from: from, to: to) do
      old_figure_complies_questions.all.each do |old_question|
        if old_question.task.nil?
          puts
          puts
          puts "    #{yellow("Skipping")} because corresponding task does not exist for #{old_question.inspect}"
          puts
          @subtract_from_expected_count += 1
          next
        end

        NestedQuestionAnswer.create!(
          nested_question_id: @nested_figure_complies_question.id,
          value_type: @nested_figure_complies_question.value_type,
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer == "Yes"),
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def old_figure_complies_questions
    Question.where(ident: OLD_FIGURES_COMPLIES_IDENT)
  end

  def verify_counts
    verify_count(
      expected: old_figure_complies_questions.count - @subtract_from_expected_count,
      actual: @nested_figure_complies_question.nested_question_answers.count,
      ident: @nested_figure_complies_question.ident
    )
  end

  def verify_count(expected:, actual:, ident:)
    if actual != expected
      raise "Count mismatch on #{ident} NestedQuestionAnswer for #{OWNER_TYPE}. Expected: #{expected} Got: #{actual}"
    end
  end
end
