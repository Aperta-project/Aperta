class DataMigrator::TaxonQuestionsMigrator < DataMigrator::Base
  TAXON_TASK = "TahiStandardTasks::TaxonTask"

  def cleanup
    idents = ["taxon.zoological", "taxon.zoological.complies", "taxon.botanical", "taxon.botantical.complies"]
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
    migrate_zoological_question
    migrate_zoological_complies_question
    migrate_botanical_question
    migrate_botanical_complies_question
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: TAXON_TASK, owner_id:nil },
    ).joins(:nested_question).destroy_all
  end

  private

  def migrate_zoological_question
    count = old_taxon_zoological_question.count
    from = "taxon.zoological"
    to = @nested_zoological_question.ident

    migrating(count: count, from: from, to: to) do
      old_taxon_zoological_question.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_zoological_question.id,
          value_type: "boolean",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer =="true"),
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def migrate_zoological_complies_question
    count = old_taxon_zoological_complies_question.count
    from = "taxon.zoological.complies"
    to = @nested_zoological_complies_question.ident

    migrating(count: count, from: from, to: to) do
      old_taxon_zoological_complies_question.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_zoological_complies_question.id,
          value_type: "boolean",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer =="true"),
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def migrate_botanical_question
    count = old_taxon_botanical_question.count
    from = "taxon.botanical"
    to = @nested_botanical_question.ident

    migrating(count: count, from: from, to: to) do
      old_taxon_botanical_question.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_botanical_question.id,
          value_type: "boolean",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer =="true"),
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def migrate_botanical_complies_question
    count = old_taxon_botanical_complies_question.count
    from = "taxon.botanical.complies"
    to = @nested_botanical_complies_question.ident

    migrating(count: count, from: from, to: to) do
      old_taxon_botanical_complies_question.all.each do |old_question|
        NestedQuestionAnswer.create!(
          nested_question_id: @nested_botanical_complies_question.id,
          value_type: "boolean",
          owner_id: old_question.task.id,
          owner_type: old_question.task.class.base_class.sti_name,
          value: (old_question.answer =="true"),
          created_at: old_question.created_at,
          updated_at: old_question.updated_at
        )
      end
    end
  end

  def create_nested_questions
    @nested_zoological_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: TAXON_TASK,
      text: "Does this manuscript describe a new zoological taxon name?",
      value_type: "boolean",
      ident: "taxon_zoological"
    ).first_or_create!

    @nested_zoological_complies_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: TAXON_TASK,
      text: "All authors comply with the Policies Regarding Submission of a new Taxon Name",
      value_type: "boolean",
      ident: "complies",
      parent_id: @nested_zoological_question.id
    ).first_or_create

    @nested_botanical_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: TAXON_TASK,
      text: "Does this manuscript describe a new botanical taxon name?",
      value_type: "boolean",
      ident: "taxon_botnical"
    ).first_or_create!

    @nested_botanical_complies_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: TAXON_TASK,
      text: "All authors comply with the Policies Regarding Submission of a new Taxon Name",
      value_type: "boolean",
      ident: "complies",
      parent_id: @nested_botanical_question.id
    ).first_or_create
  end

  def old_taxon_zoological_question
    Question.where(ident: "taxon.zoological")
  end

  def old_taxon_zoological_complies_question
    Question.where(ident: "taxon.zoological.complies")
  end

  def old_taxon_botanical_question
    Question.where(ident: "taxon.botanical")
  end

  def old_taxon_botanical_complies_question
    Question.where(ident: "taxon.botanical.complies")
  end

  def verify_counts
    verify_count(
      expected: old_taxon_zoological_question.count,
      actual: @nested_zoological_question.nested_question_answers.count,
      ident: "taxon_zoological"
    )

    verify_count(
      expected: old_taxon_zoological_complies_question.count,
      actual: @nested_zoological_complies_question.nested_question_answers.count,
      ident: "complies"
    )

    verify_count(
      expected: old_taxon_botanical_question.count,
      actual: @nested_botanical_question.nested_question_answers.count,
      ident: "taxon_botanical"
    )

    verify_count(
      expected: old_taxon_botanical_complies_question.count,
      actual: @nested_botanical_complies_question.nested_question_answers.count,
      ident: "complies"
    )
  end

  def verify_count(expected:, actual:, ident:)
    if actual != expected
      raise "Count mismatch on #{ident} NestedQuestionAnswer for #{TAXON_TASK}. Expected: #{expected} Got: #{actual}"
    end
  end
end
