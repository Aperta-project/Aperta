# VersionedText holds a snapshot of the text of the manuscript.
# There's one VersionedText for each version of the manuscript, and
# one version of the manuscript for each time the author gets to make
# changes -- minor versions for small changes, like tech checks, and
# major versions for full revisions (after a revise decision).
class VersionedText < ActiveRecord::Base
  include EventStream::Notifiable
  include Versioned
  include ViewableModel

  # Base exception class for VersionedText
  class VersionedTextError < StandardError; end

  # Exception thrown when manuscript attachments aren't `done?` and we're
  # attempting to copy data from them.
  class AttachmentNotDone < VersionedTextError; end

  belongs_to :paper
  belongs_to :submitting_user, class_name: "User"
  has_many :figures, through: :paper
  has_many :similarity_checks, dependent: :destroy

  delegate :figures, to: :paper, allow_nil: true

  before_create :insert_figures
  before_update :insert_figures, if: :original_text_changed?
  before_save :add_file_info, if: :file?

  validates :paper, presence: true
  validate :only_version_once

  delegate_view_permission_to :paper

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

  def version
    if major_version.present? && minor_version.present?
      "v#{major_version}.#{minor_version}"
    else
      'latest draft'
    end
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

  def file?
    paper.file.present?
  end

  def add_file_info
    unless paper.file.errored?
      raise AttachmentNotDone unless paper.file.done?
    end

    self.file_type = paper.file_type
    self.manuscript_s3_path = paper.file.s3_dir
    self.manuscript_filename = paper.file[:file]
  end

  def s3_full_path
    file? ? manuscript_s3_path + '/' + manuscript_filename : nil
  end

  def s3_full_sourcefile_path
    file? ? sourcefile_s3_path + '/' + sourcefile_filename : nil
  end

  def latest_version?
    self == paper.latest_version
  end

  # rubocop:disable Rails/OutputSafety
  def materialized_content
    doc = Nokogiri::HTML::DocumentFragment.parse text
    doc.css('img').each do |img|
      token = img['src']
        .match(%r{/resource_proxy/(?:figures\/)?([a-zA-Z0-9]+)})[1]
      detail_url = ResourceToken.find_by_token(token).version_urls['detail']
      signed_url = Attachment.authenticated_url_for_key(detail_url)
      img.attributes['src'].content = signed_url
    end
    doc.to_s.html_safe
  end

  private

  def only_version_once
    version_changed = (major_version_changed? || minor_version_changed?)
    return unless version_changed
    return if major_version_was.nil?
    errors.add(
      :major_version,
      "This versioned_text is not a draft. You may not change its version."
    )
  end
end
