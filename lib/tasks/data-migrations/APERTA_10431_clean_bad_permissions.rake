namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-10431: Removes bad permissions

      CustomCardTask permissions should always specify a filter_by_card_id. We
      have some old ones that don't. Fix this.
    DESC

    task aperta_10431_remove_bad_permissions: :environment do
      Permission.where('filter_by_card_id': nil, 'applies_to': CustomCardTask).destroy_all
      if Permission.where('filter_by_card_id': nil, 'applies_to': CustomCardTask).present?
        raise Exception, "A permission exists with applies: CustomCardTask and filter_by_card_id == nil!"
      end
      if PermissionsRole.where.not(permission_id: Permission.all.pluck(:id)).present?
        raise Exception, "A dangling reference in permissions_roles exists to a deleted permission"
      end
    end
  end
end
