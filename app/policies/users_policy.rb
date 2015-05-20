class UsersPolicy < ApplicationPolicy

  primary_resource :user

  def connected_users
    User.where(id: user)
  end

  def show?
    current_user == user
  end
end
