class UsersPolicy < ApplicationPolicy

  primary_resource :user

  def show?
    current_user == user
  end
end
