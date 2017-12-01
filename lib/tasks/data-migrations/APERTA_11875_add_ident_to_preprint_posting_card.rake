namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-11875: Add ident to preprint posting card
    DESC

    task aperta_11875_add_ident_to_preprint_posting_card: :environment do
      ident = 'preprint-posting--consent'
      count = 0

      CardContent.transaction do
        cards = Card.where(name: "Preprint Posting")
        raise Exception, "No cards named 'Preprint Posting' were found" if cards.blank?

        cards.each do |card|
          card.card_versions.each do |card_version|
            radio = card_version.card_contents.where(content_type: "radio").first
            if radio
              result = radio.update_attributes(ident: ident)
              if result
                count += 1
                puts "Card Content #{radio.id} version #{card_version.id} updated with '#{ident}'"
              else
                puts "Failed to update Card Content #{radio.id} #{radio.errors.full_messages}"
              end
            else
              puts "#{card.name} card #{card.id} does not have a radio button question; ident not applied."
            end
          end
        end
      end

      puts "Cards [#{count}] updated with ident '#{ident}'"
    end
  end
end
