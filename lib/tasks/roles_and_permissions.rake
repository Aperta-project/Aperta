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

  # There are multiple ways to pass arguments to a rake task,
  # including command line and invocation from another rake task.
  # This method handles all of them.

  ARG_FORMAT     = /\Aemail=(\S+)\z/
  SYNTAX_MESSAGE = 'This rake task requires a single email= parameter'.freeze

  def parse_arguments(argv, args)
    arg = argv.length == 2 ? argv[1] : args[:email]
    match = ARG_FORMAT.match(arg)
    abort(SYNTAX_MESSAGE) unless match
    email = match[1]
    abort(SYNTAX_MESSAGE) unless email.present?
    email
  end

  desc 'Assigns the Site Admin role to a user by email address'
  task :assign_site_admin, [:email] => :environment do |task, args|
    email = parse_arguments(ARGV, args)

    user = User.where(email: email).first
    abort("No user with email '#{email}' could be found.") unless user.present?
    abort("User '#{email}' is already a Site Admin.") if user.site_admin?

    user.assign_to!(role: Role.site_admin_role, assigned_to: System.first)

    status = user.site_admin? ? 'was' : 'was not'
    puts "User '#{email}' #{status} assigned the Site Admin role."
  end
end
