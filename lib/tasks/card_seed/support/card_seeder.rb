# CardSeeder will create a card with the given name and content, and it's
# idempotent.  If the given card exists it won't be created.  The content
# specified by the seed is the exact set of content that will exist in the db
# after the seed process; check card_content.rb#update_all_exactly for more
# details
class CardSeeder
  def self.seed_card(card_name, content)
    card = Card.find_or_create_by!(name: card_name, journal: Journal.first)
    content_root = CardContent.find_or_create_by!(card: card, ident: nil, parent: nil)
    content.each do |c|
      c[:parent] = content_root
      c[:card] = card
    end

    # we don't want the content_root to be affected by the update_all_exactly
    # operation, specify that ident must not be null
    CardContent.where(card: card).where.not(ident: nil).update_all_exactly!(content)
  end
end
