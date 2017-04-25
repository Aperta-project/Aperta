# Card is a container for CardContents
class Card < ActiveRecord::Base
  include EventStream::Notifiable
  include XmlSerializable

  acts_as_paranoid

  belongs_to :journal, inverse_of: :cards
  has_many :card_versions, inverse_of: :card, dependent: :destroy
  validates :name, presence: { message: "Please give your card a name." }
  validates :name, uniqueness: {
    scope: :journal,
    message:  <<-MSG.strip_heredoc
      That card name is taken for this journal.
      Please give your card a new name.
    MSG
  }

  has_one :latest_card_version,
          ->(card) { where(version: card.latest_version) },
          class_name: 'CardVersion'

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

  # The 'state' of the card reflects the state of its versions. CardVersion has
  # a 'published' boolean flag that all of this derives from.
  # * 'draft': the latest version is a draft and there are no published
  # versions. 'draft' is the default state for newly created cards
  # * 'published': the latest version is published
  # * 'published with changes': the latest version is a draft, but published
  # versions exist. This will be the state of the card after the user starts
  # prepping some changes but before publishing the latest version
  #
  # And now for the special case (of course)
  # * 'locked': locked cards are those that we (the devs) have created and are
  # not intended to be altered by end users. They show up in the card catalogue
  # but they won't open in the editor. **Locked cards do not have a journal_id**
  def state
    if latest_card_version.published?
      if journal_id
        "published"
      else
        "locked"
      end
    elsif previous_versions.exists?
      "publishedWithChanges"
    else
      "draft"
    end
  end

  def addable?
    state == "published" || state == "publishedWithChanges"
  end

  def published?
    state != "draft"
  end

  def publish!
    if latest_card_version.published?
      raise ArgumentError, "Latest card version is already published"
    end
    latest_card_version.update!(published_at: DateTime.now.utc)

    reload
  end

  def self.create_draft!(attrs)
    create_new!(attrs: attrs, published: false)
  end

  def self.create_published!(attrs)
    create_new!(attrs: attrs, published: true)
  end

  def self.create_new!(attrs:, published:)
    published_date = published ? DateTime.now.utc : nil
    Card.transaction do
      card = Card.new(attrs)
      card.card_versions << CardVersion.new(version: 1,
                                            published_at: published_date)
      card.card_versions.first.card_contents << CardContent.new(
        content_type: 'display-children'
      )
      card.save!
      card
    end
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

  def xml=(xml)
    if latest_card_version.published?
      XmlCardLoader.new_version_from_xml_string(xml, self)
    else
      XmlCardLoader.replace_draft_from_xml_string(xml, self)
    end
  end
end
