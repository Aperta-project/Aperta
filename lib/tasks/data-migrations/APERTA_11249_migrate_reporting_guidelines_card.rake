namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11249: Convert <text> labels to actual <label> labels.
    DESC

    task aperta_11249_migrate_reporting_guidelines_card: :environment do
      names = ['Additional Information', 'Reporting Guidelines']

      Card.transaction do
        cards = Card.where(name: names).all
        cards.each do |card|
          card.card_versions.each do |card_version|
            version = "#{card.journal.try(:name)} #{card.name} version #{card_version.version}"
            check_boxes = card_version.card_contents.where(content_type: "check-box").all
            puts "#{version}: has no check-box questions." if check_boxes.none?

            # rubocop:disable Rails/SkipsModelValidations
            check_boxes.each do |check_box|
              texts = check_box.entity_attributes.where(name: 'text')
              puts "#{version}: Check box #{check_box.id} has no 'text' attributes" if texts.none?
              texts.update_all(name: 'label')
            end
            # rubocop:enable Rails/SkipsModelValidations
            puts "#{version}: #{check_boxes.size} check-box text attributes(s) migrated to labels."
          end
        end
      end
    end
  end
end
