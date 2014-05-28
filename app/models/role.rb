class Role < ActiveRecord::Base
  include Roleable

  belongs_to :journal, inverse_of: :roles
  has_many :user_roles, inverse_of: :role
  has_many :users, through: :user_roles

  validates :name, presence: true
  validates :name, uniqueness: { scope: :journal_id }

  def self.can_administer_journal
    where(can_administer_journal: true)
  end

  def self.can_view_all_manuscript_managers
    where(can_view_all_manuscript_managers: true)
  end

  def self.can_view_assigned_manuscript_managers
    where(can_view_assigned_manuscript_managers: true)
  end

  def label
    "#{journal.name} #{name}"
  end
end
