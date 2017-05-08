# Card is a container for CardContents
class Card < ActiveRecord::Base
  include EventStream::Notifiable
  include XmlSerializable
  include AASM

  acts_as_paranoid

  belongs_to :journal, inverse_of: :cards
  has_many :card_versions, inverse_of: :card, dependent: :destroy
  validates :name, presence: { message: "Please give your card a name." }
  # since we use acts_as_paranoid we need to take into account whether a card
  # has been deleted for uniqueness checks
  validates :name, uniqueness: {
    scope: [:journal, :deleted_at],
    message:  <<-MSG.strip_heredoc
      That card name is taken for this journal.
      Please give your card a new name.
    MSG
  }

  has_one :latest_card_version,
          ->(card) { where(version: card.latest_version) },
          class_name: 'CardVersion'

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
  end

  def self.create_initial_draft!(attrs)
    create_new!(attrs)
  end

  def self.create_published!(attrs)
    new_card = create_new!(attrs)
    new_card.publish!
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

  def to_xml(options = {})
    attrs = {
      'name' => name,
      'required-for-submission' =>
      latest_card_version.required_for_submission
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

  private

  def publish_latest_version!
    latest_card_version.publish!
  end

  def archive_card!
    CardArchiver.archive(self)
  end
end
