module Authorizations::UserHelper
  extend ActiveSupport::Concern

  included do
    has_many :assignments
    has_many :roles, through: :assignments
  end

  def can?(permission, target)
    filter_authorized(permission, target).objects.length > 0
  end

  def filter_authorized(permission, target)
    Authorizations::Query.new(
      permission: permission,
      target: target,
      user: self
    ).all
  end
end
