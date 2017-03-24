# VersionedText holds a snapshot of the text of the manuscript.
# There's one VersionedText for each version of the manuscript, and
# one version of the manuscript for each time the author gets to make
# changes -- minor versions for small changes, like tech checks, and
# major versions for full revisions (after a revise decision).
class VersionedText < ActiveRecord::Base
  include EventStream::Notifiable
  include Versioned

  # Base exception class for VersionedText
  class VersionedTextError < StandardError; end

  # Exception thrown when manuscript attachments aren't `done?` and we're
  # attempting to copy data from them.
  class AttachmentNotDone < VersionedTextError; end

  belongs_to :paper
  belongs_to :submitting_user, class_name: "User"
  has_many :figures, through: :paper

  delegate :figures, to: :paper, allow_nil: true

  before_create :insert_figures
  before_update :insert_figures, if: :original_text_changed?
  before_save :add_file_info, if: :file?

  validates :paper, presence: true
  validate :only_version_once

  # Give the text a new MAJOR version.
  def be_major_version!
    update!(
      major_version: (paper.major_version || -1) + 1,
      minor_version: 0
    )
  end

  # Give the text a new MINOR version
  def be_minor_version!
    update!(
      major_version: (paper.major_version || 0),
      minor_version: (paper.minor_version || -1) + 1
    )
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
      d.major_version = nil
      d.minor_version = nil
      d.submitting_user = nil
      d.save! # makes duplicate of VersionedText
    end
  end

  def version_string
    version = major_version.nil? ? "(draft)" : "R#{major_version}.#{minor_version}"
    type = file_type.nil? ? "" : " (#{file_type.upcase})"
    "#{version}#{type} - #{updated_at.strftime('%b %d, %Y')}"
  end

  def file?
    paper.file.present?
  end

  def add_file_info
    raise AttachmentNotDone unless paper.file.done?

    self.file_type = paper.file_type
    self.manuscript_s3_path = paper.file.s3_dir
    self.manuscript_filename = paper.file[:file]
  end

  def s3_full_path
    # TMP: APERTA-9385: Displaying only the latest version
    paper.file.s3_dir + '/' + paper.file[:file]
    # file? ? manuscript_s3_path + '/' + manuscript_filename : nil
  end

  def s3_full_sourcefile_path
    # TMP: APERTA-9385: Displaying only the latest version
    paper.sourcefile.s3_dir + '/' + paper.sourcefile[:file]
    # file? ? sourcefile_s3_path + '/' + sourcefile_filename : nil
  end

  def latest_version?
    self == paper.latest_version
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
