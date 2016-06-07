class Decision < ActiveRecord::Base
  include EventStream::Notifiable

  VERDICTS = %w(minor_revision major_revision accept reject
                invite_full_submission)
  REVISION_VERDICTS = ['major_revision', 'minor_revision']
  TERMINAL_VERDICTS = ['accept', 'reject']
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

  validates :verdict, inclusion: { in: VERDICTS, message: 'must be a valid choice' }, if: -> { verdict }

  def register!(originating_task)
    Decision.transaction do
      paper.make_decision self
      update! major_version: paper.major_version,
              minor_version: paper.minor_version,
              registered_at: DateTime.now.utc
      originating_task.after_register self
    end
  end

  # Decisions can be appealed, and if editorial staff agrees the wrong
  # decision was made, they rescind that choice.
  def rescind!
    Decision.transaction do
      paper.rescind!
      update! rescinded: true
    end
  end

  def self.latest
    # Note: will return an unregistered decision, if there is one.
    order('registered_at DESC').limit(1).first
  end

  def latest?
    self == paper.decisions.latest
  end

  def latest_registered?
    self == paper.latest_registered_decision
  end

  def revision?
    REVISION_VERDICTS.include? verdict
  end

  def terminal?
    TERMINAL_VERDICTS.include? verdict
  end

  def rescindable?
    latest_registered? &&
      paper_in_expected_state_given_verdict? &&
      !rescinded
  end

  private

  def paper_in_expected_state_given_verdict?
    paper.publishing_state == PUBLISHING_STATE_BY_VERDICT[verdict]
  end
end
