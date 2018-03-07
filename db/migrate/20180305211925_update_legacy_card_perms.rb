class UpdateLegacyCardPerms < DataMigration
  PARTICIPANT_PERMISSIONS = ['view_participants', 'manage_participant'].freeze
  def up
    Journal.includes(:cards).all.each do |journal|
      journal.cards.each do |card|
        default_permissions = CustomCard::DefaultCardPermissions.new(journal)
        card_key = card.name.delete(' ').underscore # reverse titleize
        next unless default_permissions.permissions[card_key]
        default_permissions.apply(card_key) do |action, roles|
          CardPermissions.set_roles(card, action, roles) if PARTICIPANT_PERMISSIONS.include?(action)
        end
      end
    end
  end
end
