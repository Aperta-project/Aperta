# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

class User < ActiveRecord::Base
  include ViewableModel
  include Assignable::User
  include Authorizations::UserHelper
  include UserDevise

  include ViewableModel
  include PgSearch
  pg_search_scope :fuzzy_search, (lambda do |query|
    if query =~ /\A([^@\s]+)@/
      { against: [:email],
        using: { tsearch: { prefix: true } },
        query: query }
    else
      { against: [:first_name, :last_name, :email, :username],
        ignoring: :accents,
        using: { tsearch: { prefix: true }, trigram: { threshold: 0.3 } },
        query: query }
    end
  end)

  has_many :affiliations, inverse_of: :user

  has_many :reviewer_reports

  has_many :comments, inverse_of: :commenter, foreign_key: 'commenter_id'
  has_many \
    :participations,
    -> { joins(:role).where(roles: { name: Role::TASK_PARTICIPANT_ROLE }) },
    class_name: 'Assignment',
    inverse_of: :user
  has_many \
    :tasks,
    lambda {
      joins(assignments: :role)
        .where(roles: { name: Role::TASK_PARTICIPANT_ROLE })
    },
    through: :assignments,
    source: :assigned_to,
    source_type: 'Task' # source_type is a table name, not a specific subtype of Task
  has_many :comment_looks, inverse_of: :user
  has_many :credentials, inverse_of: :user, dependent: :destroy
  has_many :invitations, foreign_key: :invitee_id, inverse_of: :invitee
  has_many :invitations_from_me, foreign_key: :inviter_id, inverse_of: :inviter
  has_many \
    :discussion_replies,
    foreign_key: :replier_id,
    inverse_of: :replier,
    dependent: :destroy
  has_many :discussion_participants, inverse_of: :user, dependent: :destroy
  has_many :discussion_topics, through: :discussion_participants
  has_many :notifications, inverse_of: :paper

  has_one :orcid_account

  attr_accessor :login

  validates \
    :username,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: { maximum: 255 }
  validates :email, format: Devise.email_regexp
  validates :first_name, presence: true, length: { maximum: 255 }
  validates :last_name, presence: true, length: { maximum: 255 }

  validates :ned_id, uniqueness: true, allow_nil: true
  validates_with NedValidator

  mount_uploader :avatar, AvatarUploader

  after_create :add_user_role!, :associate_invites, :ensure_orcid_acccount!

  if TahiEnv.password_auth_enabled?
    devise(
      :trackable, :omniauthable, :database_authenticatable, :registerable,
      :recoverable, :rememberable, :validatable,
      authentication_keys: [:login],
      omniauth_providers: Rails.configuration.omniauth_providers
    )
  else
    devise(
      :trackable, :omniauthable,
      omniauth_providers: Rails.configuration.omniauth_providers
    )
  end

  # This associates existing invites to newly created users.
  # Existing users have their invitations associated upon the creation of the
  # invitation. See invitation.rb
  def associate_invites
    Invitation.where_email_matches(email)
              .where(invitee: nil)
              .update_all(invitee_id: id)
  end

  def ensure_orcid_acccount!
    OrcidAccount.find_or_create_by!(user_id: id)
  end

  def created_papers_for_journal(journal)
    Paper.assignments_for(user: self, role: journal.creator_role)
  end

  def password_required?
    TahiEnv.password_auth_enabled? && super
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def auto_generate_password(length = 50)
    if password_required?
      self.password = SecureRandom.urlsafe_base64(length - 1)
    end
  end

  def auto_generate_username
    # 1 in 16M chance of collision, will trigger validation error
    self.username = [first_name[0], last_name, SecureRandom.hex(6)].join('_')
  end

  def journal_admin?(journal)
    administered_journals.include? journal
  end

  # Returns the journals that this user administers. If you pass a block
  # this will yield an ActiveRecord::Relation query object that you can
  # use to put further conditions on.
  def administered_journals
    journal_query = Journal.all
    journal_query = yield(journal_query) if block_given?
    if site_admin?
      journal_query
    else
      roles = [:manage_users, :administer]
      filter_authorized_set(roles, journal_query)
    end
  end

  def accessible_journals
    site_admin? ? Journal.all : journals_thru_old_roles
  end

  def invitations_from_draft_decision
    # Includes, here, to enable selecting from the latest revision w/o
    # further db queries.
    invitations.includes([{ decision: [:paper] }, :paper]).select do |invitation|
      invitation.decision && invitation.decision.draft?
    end
  end

  def self.assigned_to_journal(journal_id)
    joins(:assignments)
      .where("assignments.assigned_to_type = 'Journal'")
      .where('assignments.assigned_to_id = ?', journal_id)
      .reorder("last_name", "first_name")
      .uniq
  end

  def self.search_users(query)
    sanitized_query = connection.quote_string(query.to_s.downcase) + '%'
    User.fuzzy_search sanitized_query
  end

  def add_user_role!
    return unless Role.user_role
    assign_to!(assigned_to: self, role: Role.user_role)
  end
end
