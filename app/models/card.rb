# Card is a container for CardContents
class Card < ActiveRecord::Base
  include EventStream::Notifiable
  include XmlSerializable
  include AASM

  acts_as_paranoid

  belongs_to :journal, inverse_of: :cards
  has_many :card_versions, inverse_of: :card, dependent: :destroy
  has_one :latest_card_version,
          ->(card) { where(version: card.latest_version) },
          class_name: 'CardVersion'

  validates :name,
    presence: {
      message: "Please give your card a name."
    },
    uniqueness: {
      scope: [:journal, :deleted_at],
      message:  <<-MSG.strip_heredoc
        That card name is taken for this journal.
        Please give your card a new name.
      MSG
    }

  # This validation call checks that both the card.workflow_only flag
  # and the latest_card_version.required_for_submission flag are not
  # both set to true

  validate :required_for_submission_and_workflow_only_cant_both_be_true

  before_destroy :ensure_destroyable

  scope :archived, -> { where.not(archived_at: nil) }

  # A given card can have several states, but be mindful that the 'state' of a
  # given card also implies something about that card's card_versions.
  # * 'draft': the latest version is a draft and there are no published
  # versions. 'draft' is the default state for newly created cards
  # * 'published': the latest version is published
  # * 'published with changes': the latest version is a draft, but published
  # versions exist. This will be the state of the card after the user starts
  # prepping some changes but before publishing the latest version
  # * 'archived': the card can't be added to new workflow templates.
  #
  # And now for the special case (of course)
  # * 'locked': locked cards are those that we (the devs) have created and are
  # not intended to be altered by end users. They show up in the card catalogue
  # but they won't open in the editor. **Locked cards do not have a journal_id**
  aasm column: :state do
    state :draft, initial: true
    state :published
    state :published_with_changes
    state :archived
    state :locked

    event :publish do
      before do |history_entry, published_by|
        if history_entry.blank?
          raise ArgumentError,
                "The :publish event must be called with a history entry"
        end
        latest_card_version.update!(
          history_entry: history_entry,
          published_by: published_by
        )
      end
      transitions from: [:draft, :published_with_changes],
                  to: :published,
                  after: :publish_latest_version!
    end

    # called when the card's xml is updated
    event :save_draft do
      transitions from: :published,
                  to: :published_with_changes
    end

    event :archive do
      transitions from: :published,
                  to: :archived,
                  after: :archive_card!
    end

    event :lock do
      transitions from: :published,
                  to: :locked,
                  guard: -> { journal_id.blank? }
    end

    event :revert do
      transitions from: :published_with_changes,
                  to: :published,
                  after: :revert_to_last_published_version!
    end
  end

  def self.create_initial_draft!(attrs)
    create_new!(attrs)
  end

  def self.create_published!(attrs)
    new_card = create_new!(attrs)
    new_card.publish!("Loaded from a configuration file")
    new_card
  end

  def self.create_new!(attrs)
    Card.transaction do
      card = Card.new(attrs)
      card.card_versions << CardVersion.new(version: 1)
      card.card_versions.first.card_contents << CardContent.new(
        content_type: 'display-children'
      )
      card.save!
      card
    end
  end

  def latest_published_card_version
    card_versions.where.not(published_at: nil).order(version: 'DESC').first
  end

  # this method is used in the shim layer between nested questions
  # on the front end and card content on the backend.
  # in those cases, we don't need the proper tree of card content,
  # as the client is simply going to look up records by their ident
  # instead of traversing them.
  def content_for_version_without_root(version_no)
    content_for_version(version_no)
      .where.not(parent_id: nil)
  end

  # can take a version number or the symbol `:latest`
  def content_for_version(version_no)
    content_root_for_version(version_no).self_and_descendants
  end

  # can take a version number or the symbol `:latest`
  def content_root_for_version(version_no)
    card_version(version_no).content_root
  end

  # all the methods dealing with card content go through
  # `card_version`
  def card_version(version_no)
    to_find = if version_no == :latest
                latest_version
              else
                version_no
              end
    card_versions.find_by!(version: to_find)
  end

  def previous_versions
    card_versions.where.not(version: latest_version)
  end

  def addable?
    published? || published_with_changes?
  end

  def replaceable?
    published_with_changes? || draft?
  end

  def self.find_by_class_name(klass_name)
    card_name = LookupClassNamespace.lookup_namespace(klass_name)
    find_by(journal: nil, name: card_name)
  end

  # rubocop:disable Style/AndOr, Metrics/LineLength
  def self.find_by_class_name!(klass_name)
    find_by_class_name(klass_name) ||
      raise(ActiveRecord::RecordNotFound, "Could not find Card with name '#{klass_name}'")
  end

  def to_xml(options = {})
    attrs = {
      'name' => name,
      'required-for-submission' =>
        latest_card_version.required_for_submission,
      'workflow-display-only' =>
        workflow_display_only
    }
    setup_builder(options).card(attrs) do |xml|
      content_root_for_version(:latest).to_xml(
        builder: xml,
        skip_instruct: true
      )
    end
  end

  def update_from_xml(xml)
    if published?
      XmlCardLoader.new_version_from_xml_string(xml, self)
      save_draft!
    elsif replaceable?
      XmlCardLoader.replace_draft_from_xml_string(xml, self)
    end
  end

  # This method checks to see if both the card.workflow_only flag
  # and the latest_card_version.required_for_submission flag are
  # both set to true. If there is no card_version available
  # abort the check.

  def required_for_submission_and_workflow_only_cant_both_be_true
    activecard = card_versions.to_a.find { |current_card| current_card.version == latest_version }
    unless workflow_display_only == false || activecard.required_for_submission == false
      errors.add(
        :workflow_display_only,
        'workflow-display-only must be set to false when required-for-submission flag is set to true'
      )
    end
  end

  private

  def publish_latest_version!
    latest_card_version.publish!
  end

  def revert_to_last_published_version!
    self.latest_version = latest_published_card_version.version
    card_versions.order(:version).last.destroy!
    save!
  end

  def archive_card!
    CardArchiver.archive(self)
  end

  def ensure_destroyable
    unless draft?
      errors.add(:base, "only draft cards can be destroyed")
      false # halt callback
    end
  end
end
