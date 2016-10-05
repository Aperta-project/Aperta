# AdHocTask is a user-customizeable task type
class AdHocTask < Task
  DEFAULT_TITLE = 'Ad-hoc'.freeze

  # Avoid resetting adhoc task title and role
  def self.restore_defaults
  end
end
