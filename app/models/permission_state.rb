class PermissionState < ActiveRecord::Base
  WILDCARD = '*'.freeze

  def self.wildcard
    where(name: WILDCARD).first_or_create!
  end

  has_and_belongs_to_many :permissions

  def self.from_strings(strings)
    strings.map do |state|
      if state.is_a?(PermissionState)
        state
      else
        PermissionState.where(name: state).first_or_create!
      end
    end
  end
end
