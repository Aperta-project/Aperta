module CustomCard
  # The purpose of this class is to migrate a legacy Task, TaskTemplate,
  # and associated Answers to a new Task based on the CustomCard::Configurations class passed in.
  #
  # It performs this migration safely without actually instantiating the
  # Task itself, so it can be run even if the legacy Task code no longer
  # exists, but the database record does.
  #
  class Migrator
    attr_reader :legacy_class_name, :configuration_class, :safe_to_destroy

    def initialize(legacy_task_klass_name:, configuration_class:)
      @legacy_class_name = legacy_task_klass_name
      @configuration_class = configuration_class
      @safe_to_destroy = true
    end

    # rubocop:disable Metrics/AbcSize
    def migrate
      old_card_version = Card.find_by!(name: legacy_class_name)
        .latest_published_card_version

      Card.transaction do
        Journal.pluck(:id).each do |journal_id|
          new_card = Card.find_by(name: configuration_class.name, journal_id: journal_id)
          new_card_version = new_card.try(:latest_published_card_version)

          if new_card_version.blank?
            Rails.logger.info "#{configuration_class.name} published card version for journal #{journal_id} doesn't exist, skipping."
            @safe_to_destroy = false
            next
          end

          migrate_tasks(journal_id, new_card_version, new_card.id)
          migrate_answers(old_card_version, new_card_version, journal_id)
        end
        if safe_to_destroy
          destroy_legacy_card
          JournalTaskType.where(kind: legacy_class_name).delete_all
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def migrate_answers(old_card_version, new_card_version, journal_id)
      # Update card content IDs of legacy answers
      new_idents = new_card_version.card_contents.pluck(:ident).compact
      old_idents = old_card_version.card_contents.pluck(:ident).compact
      raise "old idents #{old_idents} do not match new idents #{new_idents}" if Set.new(old_idents) != Set.new(new_idents)
      new_idents.each do |ident|
        update_content_id(ident, old_card_version, new_card_version, journal_id)
      end
    end

    def migrate_tasks(journal_id, new_card_version, card_id)
      # Update types for legacy tasks for current journal
      # This is sort of a cavalier approach to changing types, working under the
      # assumption that the legacy class's ruby file will already have been deleted.
      # We will get an ActiveRecord load error if we ever instantiate the full model,
      # so we are never assigning the result of our select, but immediately chaining
      # to an update, so we stay in SQL-land, so Rails won't notice the missing class.
      Task.where(type: legacy_class_name)
        .joins(:paper).where(papers: { journal_id: journal_id })
        .update_all(type: configuration_class.task_class, card_version_id: new_card_version) # rubocop:disable Rails/SkipsModelValidations

      # Update existing task templates so new papers use new custom card
      TaskTemplate.joins(:journal, :journal_task_type)
        .where(journals: { id: journal_id }, journal_task_types: { kind: legacy_class_name })
        .update_all(journal_task_type_id: nil, card_id: card_id) # rubocop:disable Rails/SkipsModelValidations
    end

    def update_content_id(ident, old_card_version, new_card_version, journal_id)
      old_content = old_card_version.card_contents.find_by(ident: ident)
      new_content = new_card_version.card_contents.find_by(ident: ident)
      Rails.logger.info "Updating #{old_content.answers.count} answers for ident '#{ident}'"
      answers = old_content.answers.joins(:paper).where(papers: { journal_id: journal_id })
      answers.update_all(card_content_id: new_content.id)
      # assert that all answers have been moved to new new card content
      return unless answers.any? && old_content.reload.answers.any?
      @safe_to_destroy = false
      raise "Failed attempting to move all answers for ident #{ident}"
    end

    def destroy_legacy_card
      # -- forcibly destroy the old card, since everything has moved to the new one
      old_card = Card.find_by!(name: legacy_class_name)
      Rails.logger.info "Destroying legacy #{legacy_class_name} card"
      old_card.forcibly_destroy!
    end
  end
end
