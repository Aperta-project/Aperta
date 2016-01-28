class PermissionState < ActiveRecord::Base
  WILDCARD = '*'

  def self.wildcard
    where(name: WILDCARD).first_or_create!
  end

  has_and_belongs_to_many :permissions
end
