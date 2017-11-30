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
          radio = card.card_version(:latest).card_contents.where(content_type: "radio").where.not(ident: ident).first
          if radio
            result = radio.update_attributes(ident: ident)
            raise Exception, "Failed to update Card Content #{radio.id} #{radio.errors.full_messages}" unless result
            count += 1
            puts "Card Content #{radio.id} updated with '#{ident}'"
          else
            puts "#{card.name} card #{card.id} does not have a radio button question; ident not applied."
          end
        end
      end

      puts "Cards [#{count}] updated with ident '#{ident}'"
    end
  end
end
