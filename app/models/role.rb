class Role < ActiveRecord::Base
  belongs_to :journal
  has_and_belongs_to_many :permissions

  def self.ensure(name, journal: nil, participates_in: [])
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
end
