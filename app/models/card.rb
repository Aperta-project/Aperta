# Card is a container for CardContents
class Card < ActiveRecord::Base
  include EventStream::Notifiable
  include CustomCardVisitors
  include XmlSerializable
  include AASM

  belongs_to :journal, inverse_of: :cards
  has_many :card_versions, inverse_of: :card, dependent: :destroy
  has_one :latest_card_version, ->(card) { where(version: card.latest_version) }, class_name: 'CardVersion'

  validates :name,
    presence: { message: "Please give your card a name." },
    uniqueness: {
      scope: :journal,
      message:  <<-MSG.strip_heredoc
        The card name of "%{value}" is already taken for this journal.
        Please give your card a new name.
      MSG
    }

  validate :check_nested_errors, :check_semantics
  before_destroy :check_destroyable
  after_destroy :clean_permissions

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

  # look for errors in nested child objects
  def check_nested_errors
    visitor = CardErrorVisitor.new
    traverse(visitor)
    most_recent_version.try do |version|
      visitor.visit(version)
      collect_errors_from(visitor)
    end
  end

  # evaluate card semantics
  def check_semantics
    traverse(CardSemanticValidator.new)
  end

  # traverse card and its latest children
  def traverse(visitor)
    root = most_recent_version.try(:content_root)
    return unless root
    root.traverse(visitor)
    collect_errors_from(visitor)
  end

  def collect_errors_from(visitor)
    visitor.report.each { |error| errors.add(:detail, message: error) }
  end

  # can take a version number or the symbol `:latest`
  def content_for_version(version_no)
    content_root_for_version(version_no).self_and_descendants
  end

  # can take a version number or the symbol `:latest`
  def content_root_for_version(version_no)
    card_version(version_no).content_root
  end

  # This method searches the in-memory versions, so it works for both create (new records) and update (persisted)
  def most_recent_version
    card_versions.detect { |card_version| card_version.version == latest_version }
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
    return latest_card_version.to_xml
    attrs = {
      'required-for-submission' =>
        latest_card_version.required_for_submission,
      'workflow-display-only' =>
        latest_card_version.workflow_display_only
    }
    setup_builder(options).card(attrs) do |xml|
      content_root_for_version(:latest).to_xml(
        builder: xml,
        skip_instruct: true
      )
    end
  end

  def xml=(xml_string)
    update_from_xml(xml_string) if xml_string.present?
  end

  def update_from_xml(xml)
    if published?
      XmlCardLoader.new_version_from_xml_string(xml, self)
      save_draft!
    elsif replaceable?
      XmlCardLoader.replace_draft_from_xml_string(xml, self)
    end
  end

  def forcibly_destroy!
    self.state = "draft"
    self.notifications_enabled = false # silence notifications
    destroy!
  end

  private

  def clean_permissions
    Permission.where(filter_by_card_id: id).delete_all
  end

  def check_destroyable
    return true if draft?
    errors.add(:base, "only draft cards can be destroyed")
    false # halt callback
  end

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
end
