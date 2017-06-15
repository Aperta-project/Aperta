namespace :card_conversions do
  desc 'Convert system cards to card_config cards'
  XML_PATH = File.join(Rails.root, 'lib', 'tasks', 'custom_card_conversion', 'configurations')

  task :competing_interests do
    desc 'Convert tasks, answers, and templates related to the Competing Interests card'

    # This file contains the raw XML for the new Competing Interests card,
    # which is safe for pasting into the admin screen's custom card editor
    xml = File.read(File.join(XML_PATH, 'competing_interests.xml'))

    # Create a new card(s) (one per journal) based on the above XML. At the
    # time of this writing, there is only one journal active in production,
    # but making this multi-journal safe was important in case either the
    # conversion gets significantly delayed, or our QA environment has multiple
    # journals configured.
    Card.transaction do
      Journal.all.pluck(:id).each do |journal_id|
        if Card.where(name: "Competing Interests", journal_id: journal_id).exists?
          puts "Competing Interests card already exists for journal " + journal_id.to_s + ", skipping."
          next
        end

        card = Card.create_initial_draft!(name: 'Competing Interests', journal_id: journal_id)
        card.update_from_xml(xml)
        card.reload.publish!('Initial version')
        puts "Competing Interests card created for Journal " + journal_id.to_s
      end
    end

    old_card_version = Card.find_by!(name: "TahiStandardTasks::CompetingInterestsTask")
      .latest_published_card_version

    # Convert "things" (enumerated below) to use the new card(s)
    Card.transaction do
      Journal.all.pluck(:id).each do |journal_id|
        new_card = Card.find_by(name: "Competing Interests", journal_id: journal_id)
        new_card_version = new_card.try(:latest_published_card_version)

        unless new_card_version.present?
          puts "Competing Interest card for journal " + journal_id.to_s + "doesn't exist, skipping."
          next
        end

        # Update types for legacy Competing Interest tasks for current journal
        tasks = Task.where(type: "TahiStandardTasks::CompetingInterestsTask")
          .joins(:paper).where(papers: { journal_id: journal_id })
        tasks.update_all(type: "CustomCardTask", card_version_id: new_card_version)

        # Update existing task templates so new papers use new Competing Interest card
        TaskTemplate.joins(:journal, :journal_task_type)
          .where(journals: { id: journal_id }, journal_task_types: { kind: 'TahiStandardTasks::CompetingInterestsTask' })
          .update_all(journal_task_type_id: nil, card_id: new_card.id)

        # Update card content IDs of legacy answers
        Answer.unscoped do # include soft deleted answers
          idents = new_card_version.card_contents.pluck(:ident).compact
          idents.each do |ident|
            old_content = old_card_version.card_contents.find_by(ident: ident)
            new_content = new_card_version.card_contents.find_by(ident: ident)
            STDOUT.puts "Updating #{old_content.answers.count} answers for ident '#{ident}'"
            answers = old_content.answers.joins(:paper)
              .where(papers: { journal_id: journal_id })
            answers.update_all(card_content_id: new_content.id)

            # rubocop:disable Style/Next
            # assert that all answers have been moved to new new card content
            if old_content.reload.answers.any?
              message = "Failed attempting to move all answers for ident #{ident}"
              STDERR.puts(message)
              raise message
            end
            # rubocop:enable Style/Next
          end
        end

        # -- destroy the old card, since everything has moved to the new one
        # -- be sure to work around:
        # --    acts_as_paranoid,
        # --    active_record callback validations,
        # --    acts_as_state_machine limitations,
        # --    event stream notifications
        old_card = Card.find_by!(name: "TahiStandardTasks::CompetingInterestsTask")
        old_card.recover if old_card.destroyed?
        old_card.state = "draft"
        old_card.notifications_enabled = false
        STDOUT.puts "Destroying legacy Competing Interest card"
        old_card.destroy_fully!

        next unless Card.where(name: "TahiStandardTasks::CompetingInterestsTask").exists?
        message = "Unable to destroy legacy Competing Interest card"
        STDERR.puts(message)
        raise message
      end
    end
  end
end
