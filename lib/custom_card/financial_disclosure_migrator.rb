module CustomCard
  class FinancialDisclosureMigrator
    # idents
    REPEAT_IDENT = 'funder--repeat'.freeze
    RECEIVED_FUNDING_IDENT = 'financial_disclosures--author_received_funding'.freeze
    FUNDER_NAME_IDENT = 'funder--name'.freeze
    FUNDER_GRANT_NUMBER_IDENT = 'funder--grant_number'.freeze
    FUNDER_WEBSITE_IDENT = 'funder--website'.freeze
    FUNDER_ADDITIONAL_COMMENTS_IDENT = 'funder--additional_comments'.freeze
    FUNDER_HAD_INFLUENCE_IDENT = 'funder--had_influence'.freeze
    FUNDER_ROLE_DESCRIPTION_IDENT = 'funder--had_influence--role_description'.freeze

    FUNDER_ATTRIBUTES_TO_IDENTS = {
      name: FUNDER_NAME_IDENT,
      grant_number: FUNDER_GRANT_NUMBER_IDENT,
      website: FUNDER_WEBSITE_IDENT,
      additional_comments: FUNDER_ADDITIONAL_COMMENTS_IDENT
    }.freeze

    def initialize
      @card = Card.where(name: CustomCard::Configurations::FinancialDisclosure.name).first!
      @card_version = @card.latest_card_version
      @card_contents = task_card_content + funder_card_content
    end

    def migrate_all
      Repetition.acts_as_list_no_update([CustomCardTask]) do
        TahiStandardTasks::FinancialDisclosureTask.includes(answers: [:card_content, :repetition], funders: { answers: [:card_content, :repetition] }).find_each do |legacy_task|
          new_task = convert_to_custom_card_task(legacy_task)
          migrate(legacy_task, new_task)
        end
      end

      # Update existing task templates so new papers use new custom card
      TaskTemplate.joins(:journal_task_type)
        .where(journal_task_types: { kind: TahiStandardTasks::FinancialDisclosureTask })
        .update_all(journal_task_type_id: nil, card_id: @card.id, title: "Financial Disclosure") # rubocop:disable Rails/SkipsModelValidations

      # Since the JournalTaskType is not longer needed, remove it for all journals
      # This is the same operation that runs in the CustomCard::Migrator class
      JournalTaskType.where(kind: "TahiStandardTasks::FinancialDisclosureTask").delete_all
    end

    def migrate(legacy_task, new_task)
      reparent_answer(new_task, legacy_task.answers, RECEIVED_FUNDING_IDENT)

      legacy_task.funders.each.with_index do |funder, i|
        repetition = Repetition.create!(task: new_task, card_content: cc_from_ident(REPEAT_IDENT), position: i)

        FUNDER_ATTRIBUTES_TO_IDENTS.each do |attr, ident|
          Answer.create!(value: funder[attr], card_content: cc_from_ident(ident), owner: new_task, repetition: repetition, paper_id: new_task.paper_id)
        end

        [FUNDER_HAD_INFLUENCE_IDENT, FUNDER_ROLE_DESCRIPTION_IDENT].each do |ident|
          reparent_answer(new_task, funder.answers, ident, repetition)
        end
      end
    end

    def convert_to_custom_card_task(legacy_task)
      new_task = legacy_task.becomes!(CustomCardTask)
      new_task.update!(card_version: @card_version, task_template: nil)
      new_task
    end

    def cc_from_ident(ident)
      @card_contents.detect { |cc| cc.ident == ident } || raise("Ident not found! #{ident}")
    end

    def reparent_answer(new_owner, answers, ident, repetition = nil)
      answer = answers.detect { |a| a.card_content.ident == ident } # answers.card_content is preloaded by this point
      return if answer.nil?

      answer.owner = new_owner
      answer.card_content = cc_from_ident(ident)
      answer.repetition = repetition
      answer.save!
    end

    def task_card_content
      @card_version.content_root.self_and_descendants
    end

    def funder_card_content
      CardContent.where(ident: [FUNDER_HAD_INFLUENCE_IDENT, FUNDER_ROLE_DESCRIPTION_IDENT])
    end
  end
end
