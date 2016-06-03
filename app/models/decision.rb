class Decision < ActiveRecord::Base
  include EventStream::Notifiable

  VERDICTS = %w(minor_revision major_revision accept reject
                invite_full_submission)

  PUBLISHING_STATE_BY_VERDICT = {
    "minor_revision" => "in_revision",
    "major_revision" => "in_revision",
    "accept" => "accepted",
    "reject" => "rejected",
    "invite_full_submission" => "invited_for_full_submission"
  }

  belongs_to :paper
  has_many :invitations
  has_many :nested_question_answers

  before_validation :increment_revision_number

  # @deprecated - use recent_ordered explictly where needed
  default_scope { self.recent_ordered }

  validates :revision_number, uniqueness: { scope: :paper_id }
  validates :verdict, inclusion: { in: VERDICTS, message: 'must be a valid choice' }, if: -> { verdict }

  # Decisions can be appealed, and if editorial staff agrees the wrong
  # decision was made, they rescind that choice.
  def rescind!
    paper.rescind!
    update!(rescinded: true,
           rescind_minor_version: paper.minor_version)
  end

  def self.recent_ordered
    order(revision_number: :desc)
  end

  def self.latest
    recent_ordered.limit(1).first
  end

  def self.completed
    where.not(verdict: nil)
  end

  def self.pending
    where(verdict: nil)
  end

  def latest?
    self == paper.decisions.latest
  end

  def latest_registered?
    self == paper.latest_registered_decision
  end

  def revision?
    verdict == 'major_revision' || verdict == 'minor_revision'
  end

  def increment_revision_number
    return if persisted?

    if latest_revision_number = paper.decisions.maximum(:revision_number)
      self.revision_number = latest_revision_number + 1
    end
  end

  def rescindable?
    latest_registered? &&
      paper_in_expected_state_given_verdict? &&
      !rescinded
  end

  def terminal?
    ["accept", "reject"].include? verdict
  end

  private

  def paper_in_expected_state_given_verdict?
    paper.publishing_state == PUBLISHING_STATE_BY_VERDICT[verdict]
  end
end
