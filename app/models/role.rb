class Role < ActiveRecord::Base
  belongs_to :journal
  has_and_belongs_to_many :permissions

  AUTHOR_ROLE = 'Author'
  REVIEWER_ROLE = 'Reviewer'

  def self.author
    where(name: AUTHOR_ROLE).first_or_create!
  end

  def self.reviewer
    where(name: REVIEWER_ROLE).first_or_create!
  end

  def self.ensure_exists(name, journal: nil, participates_in: [], &block)
    role = Role.where(name: name, journal: journal).first_or_create!

    # Ensure user passed in valid participates_in
    whitelist = [Task, Paper]
    fail StandardError, "Bad participates_in: #{participates_in}" unless \
      ((whitelist | participates_in) == whitelist)

    participates_in.each do |klass|
      role.update("participates_in_#{klass.to_s.downcase.pluralize}" => true)
    end
    yield(role) if block_given?
    role
  end

  def ensure_permission_exists(action, applies_to:, states: ['*'])
    Permission.ensure_exists(action, applies_to: applies_to, role: self,
                              states: states)
  end
end
