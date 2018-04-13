# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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

  desc 'Assigns the Site Admin role to a user by email address'
  task assign_site_admin: :environment do
    email = ENV['email']
    if email.blank?
      puts 'This rake task requires an email= parameter'
      exit(1)
    end

    user = User.find_by(email: email)
    if user.blank?
      puts "No user with email '#{email}' could be found."
      exit(1)
    end

    if user.site_admin?
      puts "User '#{email}' is already a Site Admin."
      exit(1)
    end

    user.assign_to!(role: Role.site_admin_role, assigned_to: System.first)

    status = user.site_admin? ? 'was' : 'was not'
    puts "User '#{email}' #{status} assigned the Site Admin role."
  end
end
