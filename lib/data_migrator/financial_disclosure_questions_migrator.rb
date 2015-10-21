class DataMigrator::FinancialDisclosureQuestionsMigrator < DataMigrator::Base
  FINANCIAL_DISCLOSURE_OWNER_TYPE = "TahiStandardTasks::FinancialDisclosureTask"
  FUNDER_OWNER_TYPE = "TahiStandardTasks::Funder"

  OLD_RECEIVED_FUNDING_IDENT = "financial_disclosure.received_funding"
  NEW_RECEIVED_FUNDING_IDENT = "author_received_funding"

  # There we no old questions for the following funder idents as they were
  # fields on the model. These are moving to nested questions so we clean
  # track their question text.
  NEW_FUNDER_HAD_INFLUENCE_IDENT = "funder_had_influence"
  NEW_FUNDER_ROLE_DESCRIPTION_IDENT = "funder_role_description"

  def initialize
    @subtract_from_expected_disclosure_counts = 0
  end

  def cleanup
    idents = [OLD_RECEIVED_FUNDING_IDENT]
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
    migrate_financial_disclosure_questions
    migrate_funder_questions
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: [FINANCIAL_DISCLOSURE_OWNER_TYPE, FUNDER_OWNER_TYPE], owner_id: nil }
    ).joins(:nested_question).destroy_all
  end

  private

  def create_nested_questions
    @nested_author_received_funding_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: FINANCIAL_DISCLOSURE_OWNER_TYPE,
      text: "Did any of the authors receive specific funding for this work?",
      ident: NEW_RECEIVED_FUNDING_IDENT,
      value_type: "boolean",
      position: 1
    ).first_or_create!

    @nested_funder_had_influence_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: FUNDER_OWNER_TYPE,
      text: "Did the funder have a role in study design, data collection and analysis, decision to publish, or preparation of the manuscript?",
      ident: NEW_FUNDER_HAD_INFLUENCE_IDENT,
      value_type: "boolean",
      position: 2
    ).first_or_create!

    @nested_funder_role_description_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: FUNDER_OWNER_TYPE,
      text: "Describe the role of any sponsors or funders in the study design, data collection and analysis, decision to publish, or preparation of the manuscript.",
      ident: NEW_FUNDER_ROLE_DESCRIPTION_IDENT,
      value_type: "text",
      parent: @nested_funder_had_influence_question,
      position: 1
    ).first_or_create!
  end

  def migrate_financial_disclosure_questions
    count = old_financial_disclosure_questions.count
    from = OLD_RECEIVED_FUNDING_IDENT
    to = @nested_author_received_funding_question.ident

    migrating(count: count, from: from, to: to) do
      old_financial_disclosure_questions.all.each do |old_question|
        if old_question.task.nil?
          puts
          puts
          puts "    #{yellow('Skipping')} because corresponding task does not exist for #{old_question.inspect}"
          puts
          @subtract_from_expected_disclosure_counts += 1
          next
        end

        NestedQuestionAnswer.create!(
          nested_question_id: @nested_author_received_funding_question.id,
          value_type: @nested_author_received_funding_question.value_type,
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

  def migrate_funder_questions
    funders = TahiStandardTasks::Funder.all
    @old_funder_had_influence_question = funders.count
    from = "TahiStandardTasks#Funder question (funder_had_influence, funder_influence_description)"
    to = @nested_funder_had_influence_question.ident

    migrating(count: @old_funder_had_influence_question, from: from, to: to) do
      funders.all.each do |funder|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_funder_had_influence_question.id,
          value_type: @nested_funder_had_influence_question.value_type,
          owner_id: funder.id,
          owner_type: funder.class.base_class.sti_name,
          value: (funder.funder_had_influence ? true : false),
          created_at: funder.created_at,
          updated_at: funder.updated_at
        )

        if funder.funder_influence_description
          NestedQuestionAnswer.create!(
            nested_question_id: @nested_funder_role_description_question.id,
            value_type: @nested_funder_role_description_question.value_type,
            owner_id: funder.id,
            owner_type: funder.class.base_class.sti_name,
            value: funder.funder_influence_description,
            created_at: funder.created_at,
            updated_at: funder.updated_at
          )
        end
      end
    end
  end

  def old_financial_disclosure_questions
    Question.where(ident: OLD_RECEIVED_FUNDING_IDENT)
  end

  def verify_counts
    verify_count(
      expected: old_financial_disclosure_questions.count - @subtract_from_expected_disclosure_counts,
      actual: @nested_author_received_funding_question.nested_question_answers.count,
      ident: @nested_author_received_funding_question.ident
    )

    verify_count(
      expected: @old_funder_had_influence_question,
      actual: @nested_funder_had_influence_question.nested_question_answers.count,
      ident: @nested_funder_had_influence_question.ident
    )

    verify_count(
      expected: TahiStandardTasks::Funder.where("funder_influence_description IS NOT NULL").count,
      actual: @nested_funder_role_description_question.nested_question_answers.count,
      ident: @nested_funder_role_description_question.ident
    )
  end

  def verify_count(expected:, actual:, ident:)
    if actual != expected
      raise "Count mismatch on #{ident} NestedQuestionAnswer for #{FINANCIAL_DISCLOSURE_OWNER_TYPE}. Expected: #{expected} Got: #{actual}"
    end
  end
end
