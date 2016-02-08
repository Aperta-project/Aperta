module OldRoles
  class UsersPolicy < ApplicationPolicy
    require_params :journal

    def index?
      can_administer_journal? journal
    end
  end
end
