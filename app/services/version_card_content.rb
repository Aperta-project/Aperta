# VersionCardContent will create a new CardVersion with new content
# and point the given card at the new CardVersion
class VersionCardContent
  def self.save_new_version(card, new_content)
    CardContent.transaction do
      new_version_number = card.latest_version + 1
      new_root = CardContent.create_from_hash(card, new_content)

      CardVersion.create!(
        version: new_version_number,
        card_content: new_root,
        card: card
      )

      card.update!(latest_version: new_version_number)
    end
  end
end
