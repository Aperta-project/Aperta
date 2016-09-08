class Invitation < ActiveRecord::Base
  include EventStream::Notifiable
  include AASM

  belongs_to :task
  belongs_to :decision
  has_one :paper, through: :task
  belongs_to :invitee, class_name: 'User', inverse_of: :invitations
  belongs_to :inviter, class_name: 'User', inverse_of: :invitations_from_me
  belongs_to :actor, class_name: 'User'
  has_many :attachments, as: :owner, class_name: 'InvitationAttachment', dependent: :destroy
  before_create :assign_to_draft_decision

  scope :where_email_matches,
        ->(email) { where('lower(email) = lower(?) OR lower(email) like lower(?)', email, "%<#{email}>") }

  before_validation :set_invitee_role
  validates :invitee_role, presence: true
  validates :email, format: /.+@.+/

  aasm column: :state do
    state :pending, initial: true
    state :invited do
      validates :invitee, presence: true
    end
    state :accepted
    state :declined

    # We add guards for each state transition, as a way for tasks to optionally
    # block a certain transition if desired.

    event(:invite, {
      after: [:generate_token, :associate_existing_user],
      after_commit: :notify_invitation_invited
    }) do
      transitions from: :pending, to: :invited, guards: :invite_allowed?
    end
    event(:accept,
          after_commit: :notify_invitation_accepted) do
      transitions from: :invited, to: :accepted, guards: :accept_allowed?
    end
    event(:decline,
          after_commit: :notify_invitation_declined) do
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

  # Yes, this is purposefully a little weird to call attention to it.
  # We've created APERTA-7529 to investigate making a new permission.
  def can_be_viewed_by?(user)
    user == invitee ||
      user.can?(:manage_invitations, task)
  end

  def recipient_name
    invitee.try(:full_name) || email
  end

  def rescind!
    destroy!.tap do
      task.invitation_rescinded(self)
    end
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
    self[:decline_reason].present? ? self[:decline_reason] : 'n/a'
  end

  def reviewer_suggestions
    self[:reviewer_suggestions].present? ? self[:reviewer_suggestions] : 'n/a'
  end

  def associate_existing_user
    update(invitee: User.find_by(email: email))
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
    task.invitation_invited(self)
  end

  def notify_invitation_accepted
    task.invitation_accepted(self)
  end

  def notify_invitation_declined
    task.invitation_declined(self)
  end

  def generate_token
    self.token ||= SecureRandom.hex(10)
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
