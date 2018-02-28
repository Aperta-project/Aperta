namespace :'roles-and-permissions' do
  desc 'Creates base roles and permissions'
  task seed: 'environment' do
    Role.ensure_exists(Role::USER_ROLE) do |role|
      role.ensure_permission_exists(
        :view,
        applies_to: 'User',
        states: ['*']
      )
    end

    Role.ensure_exists(Role::SITE_ADMIN_ROLE) do |role|
      role.ensure_permission_exists(Permission::WILDCARD, applies_to: 'System')
    end

    Journal.all.each do |journal|
      # JournalFactory is used to set up new journals. Rather than
      # duplicate logic just expose the step that ensures journals are
      # set up baseline roles and permissions.
      JournalFactory.ensure_default_roles_and_permissions_exist(journal)
      JournalFactory.assign_hints(journal)
    end
  end

  def check(condition, error)
    return if condition
    puts error
    exit(1)
  end

  def parse_arguments(arg)
    syntax = /\Aemail=(\S+)\z/
    error = 'This rake task requires a single email= parameter'
    match = syntax.match(arg)
    check(match, error)
    email = match[1]
    check(email.present?, error)
    email
  end

  desc 'Assigns the Site Admin role to a user by email address'
  task :assign_site_admin, [:email] => :environment do |task, args|
    arg = ARGV.length == 2 ? ARGV[1] : args[:email]
    email = parse_arguments(arg)

    user = User.find_by(email: email)
    check(user.blank?,      "No user with email '#{email}' could be found.")
    check(user.site_admin?, "User '#{email}' is already a Site Admin.")

    user.assign_to!(role: Role.site_admin_role, assigned_to: System.first)

    status = user.site_admin? ? 'was' : 'was not'
    puts "User '#{email}' #{status} assigned the Site Admin role."
  end
end
