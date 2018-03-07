class UpdateLegacyCardPerms < DataMigration
  PARTICIPANT_PERMISSIONS = ['view_participants', 'manage_participant'].freeze
  def up
    # Is this the best way to look this up with out hard coding it all over again?
    default_card_permissions = CustomCard::DefaultCardPermissions.new({}).send(:default_card_permissions)
    default_card_map = default_card_permissions.each_with_object({}) do |(card, perms), obj|
      obj[card.titleize] = perms
    end

    # default_card_map should be a hash that looks like { "Card Name" => { "Role Name" => [ "permission" ]}}
    # sorry for the nested loops of death, I'm unsure of how the data will look in stage, so I made it as a
    # journal agnostic as possible.
    Journal.includes(:cards, :roles).all.each do |journal|
      journal.cards.each do |card|
        next unless card_role_permissions = default_card_map[card.name] # only continue if the card has matching title
        card_role_permissions.each do |role_name, permissions|
          next unless role = journal.roles.detect { |j_role| j_role.name == role_name } # only continue if journal has role
          (permissions & PARTICIPANT_PERMISSIONS).each do |perm| # only add participant roles if present
            CardPermissions.add_roles(card, perm, [role])
          end
        end
      end
    end
  end
end
