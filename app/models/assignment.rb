class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :assigned_to, polymorphic: true
  has_many :permissions, through: :role

  scope :with_roles, -> (*roles) do
    joins(:role).where(roles: { name: roles })
  end

  def self.assigned_to_with_roles(klass_name, *roles)
    where(assigned_to_type: klass_name)
      .with_roles(*roles)
      .includes(:assigned_to)
      .map(&:assigned_to)
  end


  def self.users_with_roles(*roles)
    with_roles(*roles)
      .includes(:user)
      .map(&:user)
  end
end
