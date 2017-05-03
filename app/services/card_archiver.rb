# CardArchiver takes care of the various application side effects of archiving a
# card, namely setting its archived_at date and removing any TaskTemplate
# records associated to the card from manuscript manager templates
class CardArchiver
  def self.archive(card)
    Card.transaction do
      card.update!(archived_at: Time.current) unless card.archived_at.present?
      TaskTemplate.where(card: card).destroy_all
    end
    card
  end
end
