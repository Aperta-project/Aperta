# VersionedText holds a snapshot of the text of the manuscript.
# There's one VersionedText for each version of the manuscript, and
# one version of the manuscript for each time the author gets to make
# changes -- minor versions for small changes, like tech checks, and
# major versions for full revisions (after a revise decision).
class VersionedText < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :paper
  belongs_to :submitting_user, class_name: "User"
  has_many :figures, through: :paper

  delegate :figures, to: :paper, allow_nil: true

  scope :version_desc, -> { order('major_version DESC, minor_version DESC') }

  mount_uploader :source, SourceUploader # CarrierWave obj

  before_create :insert_figures
  before_update :insert_figures, if: :original_text_changed?

  validates :paper, :major_version, :minor_version, presence: true

  before_update do
    fail ActiveRecord::ReadOnlyRecord unless
      (paper.latest_version == self) && paper.editable? && submitting_user_id_was.blank?
    # use submitting_user_id_was above because it should be writable when submitting
  end

  # Make a copy of the text and give it a new MAJOR version.
  def new_major_version!
    new_version!(major_version + 1, 0)
  end

  # Make a copy of the text and give it a new MINOR version
  def new_minor_version!
    new_version!(major_version, minor_version + 1)
  end

  def submitted?
    submitting_user_id.present?
  end

  def figureful_text(**opts)
    FigureInserter.new(original_text, figures, opts).call
  end

  def insert_figures
    self.text = figureful_text
  end

  def insert_figures!
    insert_figures
    save!
  end

  private

  def creator_name
    submitting_user ? submitting_user.full_name : "(draft)"
  end

  def new_version!(new_major_version, new_minor_version)
    dup.update!(
      major_version: new_major_version,
      minor_version: new_minor_version,
      submitting_user: nil,
      source: source # makes duplicate of S3 file
    )
  end
end
