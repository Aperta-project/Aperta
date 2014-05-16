class User < ActiveRecord::Base
  has_one  :user_settings, inverse_of: :user
  has_many :affiliations, inverse_of: :user
  has_many :papers, inverse_of: :user
  has_many :paper_roles, inverse_of: :user
  has_many :journals, through: :journal_roles
  has_many :journal_roles, inverse_of: :user
  has_many :tasks, foreign_key: 'assignee_id'
  has_many :comments, inverse_of: :commenter, foreign_key: 'commenter_id'
  has_many :message_tasks, through: :comments
  has_many :message_participants, inverse_of: :participant

  attr_accessor :login

  before_create :add_default_user_settings

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  mount_uploader :avatar, AvatarUploader

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
    where(admin: true)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def image_url
    if avatar.present?
      avatar.url
    else
      "/images/profile-no-image.png"
    end
  end

  private

  def add_default_user_settings
    build_user_settings
  end
end
