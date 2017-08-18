module CustomCard
  # The purpose of this class is to migrate a legacy Task, TaskTemplate,
  # and associated Answers to a CustomCardTask.
  #
  # It performs this migration safely without actually instantiating the
  # Task itself, so it can be run even if the legacy Task code no longer
  # exists, but the database record does.
  #
  class Migrator
    attr_reader :legacy_class_name, :card_name, :safe_to_destroy

    def initialize(legacy_task_klass_name:, card_name:)
      @legacy_class_name = legacy_task_klass_name
      @card_name = card_name
      @safe_to_destroy = true
    end

    # rubocop:disable Metrics/AbcSize
    def migrate
      old_card_version = Card.find_by!(name: legacy_class_name)
        .latest_published_card_version

      Card.transaction do
        Journal.pluck(:id).each do |journal_id|
          new_card = Card.find_by(name: card_name, journal_id: journal_id)
          new_card_version = new_card.try(:latest_published_card_version)

          unless new_card_version.present?
            Rails.logger.info "#{card_name} card for journal #{journal_id} doesn't exist, skipping."
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
      Answer.unscoped do # include soft deleted answers
        idents = new_card_version.card_contents.pluck(:ident).compact
        idents.each do |ident|
          update_content_id(ident, old_card_version, new_card_version, journal_id)
        end
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
        .update_all(type: "CustomCardTask", card_version_id: new_card_version)

      # Update existing task templates so new papers use new custom card
      TaskTemplate.joins(:journal, :journal_task_type)
        .where(journals: { id: journal_id }, journal_task_types: { kind: legacy_class_name })
        .update_all(journal_task_type_id: nil, card_id: card_id)
    end

    def update_content_id(ident, old_card_version, new_card_version, journal_id)
      old_content = old_card_version.card_contents.find_by(ident: ident)
      new_content = new_card_version.card_contents.find_by(ident: ident)
      Rails.logger.info "Updating #{old_content.answers.count} answers for ident '#{ident}'"
      answers = old_content.answers.joins(:paper)
        .where(papers: { journal_id: journal_id })
      answers.update_all(card_content_id: new_content.id)
      # assert that all answers have been moved to new new card content
      return unless answers.any? && old_content.reload.answers.any?
      @safe_to_destroy = false
      raise "Failed attempting to move all answers for ident #{ident}"
    end

    def destroy_legacy_card
      # -- destroy the old card, since everything has moved to the new one
      # -- be sure to work around:
      # --    acts_as_paranoid,
      # --    active_record callback validations,
      # --    acts_as_state_machine limitations,
      # --    event stream notifications
      old_card = Card.find_by!(name: legacy_class_name)
      old_card.recover if old_card.destroyed?
      old_card.state = "draft"
      old_card.notifications_enabled = false
      Rails.logger.info "Destroying legacy #{card_name} card"
      old_card.destroy_fully!

      return unless Card.where(name: legacy_class_name).exists?
      message = "Unable to destroy legacy #{card_name} card"
      Rails.error.info(message)
      raise message
    end
  end
end
