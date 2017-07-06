# Create a new card (one per journal) based on the referenced XML file.
class AddCardToAllJournals
  XML_PATH = File.join(Rails.root, 'lib', 'tasks', 'custom_card_conversion', 'configurations')

  attr_reader :config_file_name, :card_name

  # config_file_name is an XML file placed in /lib/tasks/custom_card_conversion/configurations,
  # which contains the raw XML that would normally be pasted into the admin screen's custom
  # card editor. It's contents need to contain all the idents associated with the legacy card
  # being replaced. See competing_interests.xml for an example
  # card_name is the user-facing name, e.g., "Competing Interests", of the card being replaced
  def initialize(config_file_name, card_name)
    @config_file_name = config_file_name
    @card_name = card_name
  end

  def from_configuration_file
    xml = File.read(File.join(XML_PATH, config_file_name))

    Card.transaction do
      Journal.all.pluck(:id).each do |journal_id|
        if Card.where(name: card_name, journal_id: journal_id).exists?
          Rails.logger.info "#{card_name} card already exists for journal #{journal_id}, skipping."
        else
          load_single(xml, journal_id)
        end
      end
    end
  end

  private

  def load_single(xml, journal_id)
    card = Card.create_initial_draft!(name: card_name, journal_id: journal_id)
    card.update_from_xml(xml)
    card.reload.publish!('Initial version')
    Rails.logger.info "#{card_name} card created for Journal #{journal_id}"
  end
end
