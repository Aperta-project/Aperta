##
# Simple matcher to test if a user has a role assigned.
#
# Takes the role name as a string, doesn't take the actual role record.

RSpec::Matchers.define :have_role_name do |expected_role_name|
  match do |user|
    user.roles.where(name: expected_role_name).present?
  end

  failure_message do
    "Expected user to have the role, '#{expected_role_name}'"
  end

  failure_message_when_negated do
    "Expected user to not have the role, '#{expected_role_name}'"
  end
end
