namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7457: Removes 'view_profile' permission on User

      The permission in use is now a regular 'view' permission.
    DESC
    task remove_view_profile_permission: :environment do
      Permission.where(action: 'view_profile').destroy_all
    end
  end
end
