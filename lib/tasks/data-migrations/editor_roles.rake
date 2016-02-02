namespace :data do
  namespace :migrate do
    namespace :editors do
      desc 'Migrates the Editor to new R&P Editor role'
      task make_into_new_roles: :environment do
        # Any one who is a journal admin in the old roles gets moved to
        # the Staff Admin role in the new R&P. Likewise, any one who has
        # a role with can_view_all_manuscript_managers set to true gets
        # put into the same bucket (for now).
        OldRole.where(name: 'Editor').all.each do |old_role|
          old_role.users.each do |user|
            puts "Assigning #{user.full_name} <#{user.email}> as #{old_role.name} on '#{old_role.journal.name}' Journal"
            Assignment.where(
              user: user,
              role: old_role.journal.roles.internal_editor,
              assigned_to: old_role.journal
            ).first_or_create!
          end
        end
      end
    end
  end
end
