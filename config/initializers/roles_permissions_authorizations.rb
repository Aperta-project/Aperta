# This file must load after the devise initializer

# This configuration defines how you get access to object based on your
# assignments
Authorizations.configure do |authorizations_config|
  authorizations_config.assignment_to(
    Journal,
    authorizes: Paper,
    via: :papers)
end
