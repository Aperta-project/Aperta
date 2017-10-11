# Migration to convert newlines to break tags in tech check bodies

namespace :data do
  namespace :migrate do
    desc 'It fixes the xml for the upload manuscript task on CI and RC'
    task fix_upload_ms_card: :environment do
      card_name = 'Upload Manuscript'
      file_path = Rails.root.join('lib', 'custom_card', 'configurations', 'xml_content', 'upload_manuscript.xml')
      new_xml = File.read(file_path)
      Card.transaction do
        Journal.pluck(:id).map do |journal_id|
          existing_card = Card.find_by(name: card_name, journal_id: journal_id)
          old_card_version = existing_card.try(:latest_published_card_version)

          if old_card_version.blank?
            Rails.logger.info "#{card_name} published card version for journal #{journal_id} doesn't exist, skipping."
            next
          end

          Rails.logger.info "updating card xml. Previous xml was:"
          Rails.logger.info existing_card.to_xml

          Rails.logger.info "new xml is:"
          Rails.logger.info new_xml

          existing_card.update_from_xml(new_xml)
          existing_card.reload.publish!('fix initial version')
          new_card_version = existing_card.reload.latest_card_version
          raise "New card version #{new_card_version} should not equal old version #{old_card_version}" if new_card_version.id == old_card_version.id

          # migrate everything to that newer version
          Task.where(card_version: old_card_version).update_all(card_version_id: new_card_version.id) # rubocop:disable Rails/SkipsModelValidations
        end
      end
    end
  end
end
