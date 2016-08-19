class Decision < ActiveRecord::Base
  include EventStream::Notifiable

  VERDICTS = %w(minor_revision major_revision accept reject
                invite_full_submission)

  belongs_to :paper
  has_many :invitations
  has_many :nested_question_answers

  before_validation :increment_revision_number

  # @deprecated - use recent_ordered explictly where needed
  default_scope { self.recent_ordered }

  validates :revision_number, uniqueness: { scope: :paper_id }
  validates :verdict, inclusion: { in: VERDICTS, message: 'must be a valid choice' }, if: -> { verdict }

  validate do
    if letter_changed? && completed? && persisted?
      errors.add(:letter, 'Letter can only change on draft decisions')
    end
    if verdict_changed? && completed? && persisted?
      errors.add(:verdict, 'Verdict can only change on draft decisions')
    end
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

  def revision?
    verdict == 'major_revision' || verdict == 'minor_revision'
  end

  def increment_revision_number
    return if persisted?

    if latest_revision_number = paper.decisions.maximum(:revision_number)
      self.revision_number = latest_revision_number + 1
    end
  end

  def draft?
    draft_states = %w(submitted initially_submitted)
    latest? && draft_states.include?(paper.publishing_state)
  end

  def completed?
    !draft?
  end
end
