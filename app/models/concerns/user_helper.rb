# Provides convenience/helper methods intended for use on the User model.
module UserHelper
  extend ActiveSupport::Concern

  included do
    has_many :assignments
    has_many :roles, through: :assignments
  end

  def can?(permission, target)
    # TODO: Remove this when site_admin is no more
    return true if site_admin
    filter_authorized(permission, target).objects.length > 0
  end

  def filter_authorized(permission, target, participations_only: :default)
    Authorizations::Query.new(
      permission: permission,
      target: target,
      user: self,
      participations_only: participations_only
    ).all
  end

  def assign_as(role_name, to:)
    unless to.respond_to? :journal
      fail NoMethodError <<-ERROR.strip_heredoc
        Sorry, I don't know which journal you want this role to apply to.
        #{to.class.name} needs a :journal method.
      ERROR
    end

    role = role_for_assignment(role_name, to.journal)
    assignments.create(role: role, assigned_to: to)
  end

  private

  def role_for_assignment(role_name, journal)
    role = journal.roles.find_by(name: role_name) ||
           Role.find_by(name: role_name, journal: nil)

    return role if role

    fail ActiveRecord::RecordNotFound <<-ERROR.strip_heredoc
        Sorry, I couldn't find a role #{role_name} in #{journal},
        or with no journal at all.
      ERROR
  end
end
