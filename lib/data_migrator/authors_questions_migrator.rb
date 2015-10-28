class DataMigrator::AuthorsQuestionsMigrator < DataMigrator::Base

  def cleanup
    puts
    puts yellow <<-EOT.gsub(/^\s*\|/, '')
      |Author has no old questions to cleanup, but needs following fields
      |removed the database in an actual DB migration:
      |
      |   * corresponding
      |   * deceased
      |   * contributions
      |
    EOT
    puts
  end

  def initialize
    @owner_type = "Author"
  end

  def migrate!
    @expected_count = 0
    create_nested_questions
    migrate_to_questions
    verify_counts
  end

  def reset
    NestedQuestionAnswer.where(
      nested_questions: { owner_type: @owner_type, owner_id: nil }
    ).joins(:nested_question).destroy_all
  end

  private

  def create_nested_questions
    @published_as_corresponding_author_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: @owner_type,
      ident: "published_as_corresponding_author",
      value_type: "boolean",
      text: "This person will be listed as the corresponding author on the published article",
      position: 1
    ).first_or_create!

    @deceased_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: @owner_type,
      ident: "deceased",
      value_type: "boolean",
      text: "This person is deceased",
      position: 2
    ).first_or_create!

    @contributions_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: @owner_type,
      ident: "contributions",
      value_type: "question-set",
      text: "Author Contributions",
      position: 3
    ).first_or_create!

    @conceived_and_designed_experiments_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: @owner_type,
      parent_id: @contributions_question.id,
      ident: "conceived_and_designed_experiments",
      value_type: "boolean",
      text: "Conceived and designed the experiments",
      position: 1
    ).first_or_create!

    @performed_the_experiments_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: @owner_type,
      parent_id: @contributions_question.id,
      ident: "performed_the_experiments",
      value_type: "boolean",
      text: "Performed the experiments",
      position: 2
    ).first_or_create!

    @analyzed_data_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: @owner_type,
      parent_id: @contributions_question.id,
      ident: "analyzed_data",
      value_type: "boolean",
      text: "Analyzed the data",
      position: 3
    ).first_or_create!

    @contributed_tools_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: @owner_type,
      parent_id: @contributions_question.id,
      ident: "contributed_tools",
      value_type: "boolean",
      text: "Contributed reagents/materials/analysis tools",
      position: 4
    ).first_or_create!

    @contributed_writing_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: @owner_type,
      parent_id: @contributions_question.id,
      ident: "contributed_writing",
      value_type: "boolean",
      text: "Contributed to the writing of the manuscript",
      position: 5
    ).first_or_create!

    @other_question = NestedQuestion.where(
      owner_id: nil,
      owner_type: @owner_type,
      parent_id: @contributions_question.id,
      ident: "other",
      value_type: "text",
      text: "Other",
      position: 6
    ).first_or_create!
  end

  def migrate_to_questions
    migrating(count: Author.count, from: "Author#corresponding,deceased", to: "NestedQuestionAnswer") do
      Author.all.each do |author|
        NestedQuestionAnswer.create!(
          nested_question_id: @published_as_corresponding_author_question.id,
          value_type: @published_as_corresponding_author_question.value_type,
          owner_id: author.id,
          owner_type: author.class.base_class.sti_name,
          value: author.corresponding,
          created_at: author.created_at,
          updated_at: author.updated_at
        )
        @expected_count += 1

        NestedQuestionAnswer.create!(
          nested_question_id: @deceased_question.id,
          value_type: @deceased_question.value_type,
          owner_id: author.id,
          owner_type: author.class.base_class.sti_name,
          value: author.deceased,
          created_at: author.created_at,
          updated_at: author.updated_at
        )
        @expected_count += 1

        contributions = []
        if author[:contributions]
          contributions = YAML.load(author[:contributions])
        end

        contributions.each do |contribution|
          nested_question = case contribution
            when /Conceived and designed the experiments/
              @conceived_and_designed_experiments_question
            when /Performed the experiments/
              @performed_the_experiments_question
            when /Analyzed the data/
              @analyzed_data_question
            when /Contributed reagents.materials.analysis tools/
              @contributed_tools_question
            when /Contributed to the writing of the manuscript/
              @contributed_writing_question
            else
              @other_question
            end

          NestedQuestionAnswer.create!(
            nested_question_id: nested_question.id,
            value_type: nested_question.value_type,
            owner_id: author.id,
            owner_type: author.class.base_class.sti_name,

            # the other contribution is a user-entered text value, the rest
            # are simply true if they were checked by the user.
            value: (nested_question == @other_question ? contribution : true),
            created_at: author.created_at,
            updated_at: author.updated_at
          )
          @expected_count += 1
        end
      end
    end
  end

  def verify_counts
    verify_count(
      expected: @expected_count,
      actual: NestedQuestionAnswer.includes(:nested_question).where(nested_questions: { owner_type: @owner_type, owner_id: nil }).count
    )
  end

  def verify_count(expected:, actual:)
    if actual != expected
      raise "Count mismatch on NestedQuestionAnswer for #{@owner_type}. Expected: #{expected} Got: #{actual}"
    end
  end
end
