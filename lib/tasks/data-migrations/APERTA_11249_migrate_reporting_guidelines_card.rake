namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11249: Convert <text> labels to actual <label> labels.
    DESC

    task aperta_11249_migrate_reporting_guidelines_card: :environment do
      cards = ['Additional Information', 'Reporting Guidelines']
      cards.each do |name|
        CardContent.transaction do
          card = Card.where(name: name).first
          raise Exception, "No card named '#{name}'" unless card

          check_boxes = card.card_version(:latest).card_contents.where(content_type: "check-box").all
          raise Exception, "Card has no check-box questions." unless check_boxes

          # rubocop:disable Rails/SkipsModelValidations
          check_boxes.each do |check_box|
            check_box.entity_attributes.where(name: 'text').update_all(name: 'label')
          end
          # rubocop:enable Rails/SkipsModelValidations

          p "#{name}: #{check_boxes.size} check-box text element(s) migrated to labels."
        end
      end
    end
  end
end
