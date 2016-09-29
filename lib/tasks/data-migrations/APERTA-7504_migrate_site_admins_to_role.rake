namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-7504: Migrates site admins to using the Site Admin role.
    DESC
    task migrate_site_admins_to_role: :environment do
      if User.column_names.include?('site_admin')
        the_system = System.first || System.create!

        site_admin_role = Role.ensure_exists(Role::SITE_ADMIN_ROLE) do |role|
          role.ensure_permission_exists(
            Permission::WILDCARD,
            applies_to: System.name
          )
        end

        site_admins = User.where(site_admin: true)
        expected_site_admin_count = site_admins.count
        site_admins.each do |user|
          puts "Making User id=#{user.id} full_name=#{user.full_name} a Site Admin"
          user.assign_to!(assigned_to: the_system, role: site_admin_role)
        end

        migrated_site_admin_count = Role.site_admin_role.users.count
        if expected_site_admin_count != migrated_site_admin_count
          fail <<-ERROR.strip_heredoc
            There were #{expected_site_admin_count} site admins assigned
            by the User#site_admin column, but after migrating there were
            only #{migrated_site_admin_count} assigned thru the Site Admin
            role.
          ERROR
        end

      else
        puts <<-DESC
          The data:migrate:migrate_site_admins_to_role is no longer
          necessary and can be removed
        DESC
      end
    end

    desc <<-DESC
      APERTA-7504: Migrates Site Admin role back to the users.site_admin column.

      This is intended to be run as part of a down migration.
    DESC
    task :migrate_site_admin_role_back_to_column do
      User.reset_column_information

      expected_site_admin_count = Role.site_admin_role.users.count
      if User.column_names.include?('site_admin')
        Role.site_admin_role.users.update_all site_admin: true
        Role.site_admin_role.destroy

        migrated_site_admin_count = User.where(site_admin: true).count
        if expected_site_admin_count != migrated_site_admin_count
          fail <<-ERROR.strip_heredoc
            There were #{expected_site_admin_count} site admins assigned
            thru the Site Admin role, but after migrating them to the
            User#site_admin column there were only #{migrated_site_admin_count}.
          ERROR
        end
      else
        fail <<-ERROR.strip_heredoc
          The users table did not have a site_admin column. This is necessary
          in order this down migration to run.
        ERROR
      end
    end
  end
end
