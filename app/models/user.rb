class User < ActiveRecord::Base
  has_many :papers
  has_many :journal_roles
  has_many :tasks, foreign_key: 'assignee_id'
  has_one :user_settings

  attr_accessor :login

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         authentication_keys: [:login]


  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def self.admins
    where admin: true
  end

  def self.admins_for(journal)
    joins(:journal_roles).where("journal_roles.journal_id" => journal.id, "journal_roles.admin" => true)
  end

  def self.editors_for(journal)
    joins(:journal_roles).where("journal_roles.journal_id" => journal.id, "journal_roles.editor" => true)
  end

  def self.reviewers_for(journal)
    joins(:journal_roles).where("journal_roles.journal_id" => journal.id, "journal_roles.reviewer" => true)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

end
