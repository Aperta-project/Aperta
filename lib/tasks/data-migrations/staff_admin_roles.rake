namespace :data do
  namespace :migrate do
    namespace :admins do
      desc 'Migrates the Journal Admin and other admin-y users to new R&P'
      task make_into_new_roles: :environment do
        # Any one who is a journal admin in the old roles gets moved to
        # the Staff Admin role in the new R&P. Likewise, any one who has
        # a role with can_view_all_manuscript_managers set to true gets
        # put into the same bucket (for now).
        OldRole.where("
          kind='admin' OR can_view_all_manuscript_managers = 't'
        ").all.each do |old_role|
          old_role.users.each do |user|
            staff_admin_role = Role.staff_admin
            journals_administered = user.journals_thru_old_roles.merge(
              OldRole.can_administer_journal
            )
            journals_administered.each do |journal|
              puts "Assigning #{user.full_name} <#{user.email}> as #{staff_admin_role.name} on '#{journal.name}' Journal"
              Assignment.where(
                user: user,
                role: staff_admin_role,
                assigned_to: journal
              ).first_or_create!
            end
          end
        end
      end
    end
  end
end
