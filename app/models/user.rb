class User < ActiveRecord::Base

  include UserDevise
  searchable ignore_attribute_changes_of: [:encrypted_password, :avatar] do
    integer :id
    text :username, :first_name, :last_name, :email
    text :full_name do
      full_name
    end
  end

  has_many :affiliations, inverse_of: :user
  has_many :submitted_papers, inverse_of: :creator, class_name: 'Paper'
  has_many :paper_roles, inverse_of: :user
  has_many :user_roles, inverse_of: :user
  has_many :roles, through: :user_roles
  has_many :journals, ->{ uniq }, through: :roles
  has_many :user_flows, inverse_of: :user, dependent: :destroy
  has_many :flows, through: :user_flows
  has_many :comments, inverse_of: :commenter, foreign_key: 'commenter_id'
  has_many :participations, dependent: :destroy
  has_many :tasks, through: :participations
  has_many :comment_looks, inverse_of: :user
  has_many :credentials, inverse_of: :user, dependent: :destroy
  has_many :assigned_papers, ->{ uniq }, through: :paper_roles, class_name: 'Paper', source: :paper

  attr_accessor :login

  validates :username, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 255 }
  validates_format_of :username, with: /\A[A-Za-z\d_]+\z/, multiline: true
  validates :email, format: Devise.email_regexp
  validates :first_name, length: { maximum: 255 }
  validates :last_name, length: { maximum: 255 }

  mount_uploader :avatar, AvatarUploader

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable,
         authentication_keys: [:login],
         omniauth_providers: [:orcid, :cas]

  def possible_flows
    Flow.where("role_id IN (?) OR role_id IS NULL", role_ids)
  end

  def self.site_admins
    where(site_admin: true)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def can_view_flow_manager?
    roles.can_view_flow_manager.present?
  end

  def auto_generate_password(length=10)
    self.password = SecureRandom.urlsafe_base64(length-1)
  end

  def administered_journals
    if site_admin?
      Journal.all
    else
      journals.merge(Role.can_administer_journal)
    end
  end

  def self.search_users(query: nil, assigned_users_in_journal_id: nil)
    if query
      sanitized_query = connection.quote_string(query.to_s.downcase) + '%'
      User.where("lower(username) LIKE '#{sanitized_query}' OR lower(first_name) LIKE '#{sanitized_query}' OR lower(last_name) LIKE '#{sanitized_query}'")
    elsif assigned_users_in_journal_id
      User.joins(user_roles: :role).where('roles.journal_id = ?', assigned_users_in_journal_id).uniq
    end
  end
end
