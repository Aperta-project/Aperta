# CardVersion joins a Card to the different versions of its
# CardContent.  The card_versions table itself can also serve
# as a container for information we need to version that isn't
# card content
class CardVersion < ActiveRecord::Base
  acts_as_paranoid
  validates_as_paranoid

  belongs_to :card, inverse_of: :card_versions
  belongs_to :published_by, class_name: 'User'
  has_many :card_contents, -> {includes(:content_attributes)}, inverse_of: :card_version, dependent: :destroy

  validates :card, presence: true
  validates :card_contents, presence: true
  validate :submittable_state

  # the `roots` scope comes from `awesome_nested_set`
  has_one :content_root, -> { roots }, class_name: 'CardContent'
  scope :required_for_submission, -> { where(required_for_submission: true) }
  scope :published, -> { where.not(published_at: nil) }
  scope :unpublished, -> { where(published_at: nil) }

  validates_uniqueness_of_without_deleted :version,
    scope: :card_id,
    message: "Card version numbers are unique for a given card"

  validates :history_entry, presence: true, if: -> { published? }

  def published?
    published_at.present?
  end

  def publish!
    update!(published_at: Time.current)
  end

  def traverse(visitor)
    card_contents.each { |card_content| card_content.traverse(visitor) }
  end

  def create_default_answers(task)
    puts "Card contents: #{card_contents.size} / #{card_contents.count}"
    default_answers = card_contents.select { |content| content.default_answer_value.present? }
    puts "Default answers: #{default_answers.size}"
    default_answers.each do |content|
      answer = task.answers.create(
        card_content: content,
        paper: task.paper,
        value: content.default_answer_value
      )
      puts "Answer #{answer}"
      puts "Answer errors: #{answer.errors.full_messages}" if answer.errors.any?
      answer
    end
  end

  private

  def submittable_state
    # prevent case where the card
    # hidden from sidebar, but required to
    # be completed in order to submit the paper.
    if workflow_display_only? && required_for_submission?
      msg = "cannot be both workflow only and required for submission"
      errors.add(:workflow_display_only, msg)
    end
  end
end
