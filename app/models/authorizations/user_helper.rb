module Authorizations::UserHelper
  extend ActiveSupport::Concern

  included do
    has_many :assignments
    has_many :roles, through: :assignments
  end

  def can?(permission, target)
    enumerate_targets(permission, target).objects.length > 0
  end

  def enumerate_targets(permission, target)
    Authorizations::Query.new(
      permission: permission,
      target: target,
      user: self
    ).all
  end
end
