class Invitation < ActiveRecord::Base
  include EventStream::Notifiable
  include AASM
  include Tokenable
  include CustomCastTypes
  include ViewableModel

  attribute :body, HtmlString.new
  attribute :decline_reason, HtmlString.new
  attribute :reviewer_suggestions, HtmlString.new

  belongs_to :task
  belongs_to :decision
  has_one :paper, through: :task
  belongs_to :invitee, class_name: 'User', inverse_of: :invitations
  belongs_to :inviter, class_name: 'User', inverse_of: :invitations_from_me
  belongs_to :actor, class_name: 'User'
  has_many :alternates, class_name: 'Invitation', foreign_key: 'primary_id'
  has_many :attachments, as: :owner, class_name: 'InvitationAttachment', dependent: :destroy
  belongs_to :primary, class_name: 'Invitation'
  before_create :assign_to_draft_decision

  EMAIL_MATCH = 'lower(email) = lower(?) OR lower(email) like lower(?)'.freeze
  scope :where_email_matches, lambda {|email|
    where(EMAIL_MATCH, email, "%<#{email}>")
  }

  before_validation :set_invitee_role
  validates :invitee_role, presence: true
  validates :email, format: /.+@.+/
  validates :task, presence: true

  belongs_to :invitation_queue
  acts_as_list scope: :invitation_queue, add_new_at: :bottom

  scope :not_pending, -> { where.not(state: "pending") }
  scope :pending, -> { where(state: "pending") }
  scope :rescinded, -> { where(state: "rescinded") }
  scope :invited, -> { where(state: "invited") }
  scope :grouped_alternates, -> { where.not(primary: nil) }
  scope :newest_first, -> { order(created_at: :desc) }

  def ungrouped_primary?
    !has_alternates? && !is_alternate?
  end

  def has_alternates?
    alternates.exists?
  end

  def is_alternate?
    primary_id.present?
  end

  aasm column: :state do
    state :pending, initial: true
    state :invited do
      validates :invitee, presence: true
    end
    state :accepted
    state :declined
    state :rescinded

    # We add guards for each state transition, as a way for tasks to optionally
    # block a certain transition if desired.

    event(:invite,
      after_commit: [:set_invitee,
                     :set_invited_at,
                     :notify_invitation_invited]) do
      transitions from: :pending, to: :invited, guards: :invite_allowed?
    end

    event(:rescind,
      after_commit: [:set_rescinded_at, :notify_invitation_rescinded]) do
      transitions from: [:invited, :accepted], to: :rescinded
    end

    event(:accept,
      after_commit: [:set_accepted_at, :notify_invitation_accepted]) do
      transitions from: :invited, to: :accepted, guards: :accept_allowed?
    end
    event(:decline,
      after_commit: [:set_declined_at, :notify_invitation_declined]) do
      transitions from: :invited, to: :declined, guards: :decline_allowed?
    end
  end

  def self.find_uninvited_users_for_paper(possible_users, paper)
    invited_users = where(
      decision_id: paper.draft_decision.id,
      state: ["invited", "accepted", "declined"]
    ).includes(:invitee).map(&:invitee)
    possible_users - invited_users
  end

  def user_can_view?(user)
    user == invitee || user.can?(:manage_invitations, task)
  end

  def recipient_name
    invitee.try(:full_name) || email
  end

  # Normalize emails to addr-spec
  #
  # we currently receive emails that take the form of an
  #   * addr-spec (what we want)
  #   * angle-addr = [CFWS] "<" addr-spec ">" [CFWS] / obs-angle-addr
  # this setter will normalize angle-addr to addr-spec
  # https://tools.ietf.org/html/rfc2822 for more info
  def email=(new_email)
    regexp = /
      (?:.+<)     # name and open angle bracket
      ([^>]+)     # the actual email address (addr-spec)
      (?:>)       # closing bracket
    /x
    normalized = regexp =~ new_email ? Regexp.last_match(1) : new_email
    super(normalized.strip)
  end

  def feedback_given?
    self[:decline_reason].present? || self[:reviewer_suggestions].present?
  end

  def decline_reason
    self[:decline_reason].present? ? self[:decline_reason] : 'No feedback provided'
  end

  def reviewer_suggestions
    self[:reviewer_suggestions].present? ? self[:reviewer_suggestions] : 'None'
  end

  def set_invitee
    update(invitee: User.find_by(email: email))
  end

  def set_body
    scenario = InvitationScenario.new(self)
    letter_templates = paper.journal.letter_templates
    ident = invitee_role == Role::REVIEWER_ROLE ? 'reviewer-invite' : 'academic-editor-invite'
    letter_template = letter_templates.find_by(ident: ident)
    update(body: letter_template.render(scenario).body)
  end

  private

  def assign_to_draft_decision
    self.decision = paper.draft_decision
  end

  def add_authors_to_information(invitation)
    authors_list = TahiStandardTasks::AuthorsList.authors_list(paper)
    return unless authors_list.present?
    invitation.update! information: authors_list
  end

  def notify_invitation_invited
    add_authors_to_information(self)
    notify(action: 'invited')
    task.invitation_invited(self)
  end

  def notify_invitation_accepted
    notify(action: 'accepted')
    task.invitation_accepted(self)
  end

  def notify_invitation_declined
    notify(action: 'declined')
    task.invitation_declined(self)
  end

  def notify_invitation_rescinded
    notify(action: 'rescinded')
    task.invitation_rescinded(self)
  end

  def set_invited_at
    update!(invited_at: Time.current.utc)
  end

  def set_accepted_at
    update!(accepted_at: Time.current.utc)
  end

  def set_declined_at
    update!(declined_at: Time.current.utc)
  end

  def set_rescinded_at
    update!(rescinded_at: Time.current.utc)
  end

  def invite_allowed?
    task.invite_allowed?(self)
  end

  def accept_allowed?
    task.accept_allowed?(self)
  end

  def decline_allowed?
    task.decline_allowed?(self)
  end

  def event_stream_serializer(user: nil)
    InvitationIndexSerializer.new(self, root: "invitation")
  end

  def set_invitee_role
    self.invitee_role = task.invitee_role if task
  end
end
