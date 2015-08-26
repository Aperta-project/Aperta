class Decision < ActiveRecord::Base
  extend HasFeedActivities

  belongs_to :paper
  has_many :invitations
  has_many :questions

  before_validation :increment_revision_number

  default_scope { order('revision_number DESC') }

  validates :revision_number, uniqueness: { scope: :paper_id }
  validate :verdict_valid?, if: -> { verdict }

  VERDICTS = ['minor_revision', 'major_revision', 'accept', 'reject']

  feed_activities feed_names: ['manuscript'], subject: :paper do
    activity(:decided) { "#{verdict.titleize} was sent to author" }
  end

  def verdict_valid?
    VERDICTS.include?(verdict) || errors.add(:verdict, "must be a valid choice.")
  end

  def self.latest
    first
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
end
