# VersionedText holds a snapshot of the text of the manuscript.
# There's one VersionedText for each version of the manuscript, and
# one version of the manuscript for each time the author gets to make
# changes -- minor versions for small changes, like tech checks, and
# major versions for full revisions (after a revise decision).
class VersionedText < ActiveRecord::Base
  include EventStream::Notifiable
  include Versioned

  belongs_to :paper
  belongs_to :submitting_user, class_name: "User"
  has_many :figures, through: :paper

  delegate :figures, to: :paper, allow_nil: true

  before_create :insert_figures
  before_update :insert_figures, if: :original_text_changed?

  validates :paper, presence: true
  validate :only_version_once

  # Give the text a new MAJOR version.
  def be_major_version!
    update!(
      major_version: (paper.major_version || -1) + 1,
      minor_version: 0)
  end

  # Give the text a new MINOR version
  def be_minor_version!
    update!(
      major_version: (paper.major_version || 0),
      minor_version: (paper.minor_version || -1) + 1)
  end

  def submitted?
    submitting_user_id.present?
  end

  def figureful_text(**opts)
    FigureInserter.new(original_text, figures.reload, opts).call
  end

  def insert_figures
    self.text = figureful_text
  end

  def insert_figures!
    insert_figures
    save!
  end

  def new_draft!
    dup.tap do |d|
      d.update!(
        major_version: nil,
        minor_version: nil,
        submitting_user: nil) # makes duplicate of S3 file
    end
  end

  private

  def only_version_once
    version_changed = (major_version_changed? || minor_version_changed?)
    return unless version_changed
    return if major_version_was.nil?
    errors.add(
      :major_version,
      "This versioned_text is not a draft. You may not change its version.")
  end
end
