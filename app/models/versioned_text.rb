# VersionedText holds a snapshot of the text of the manuscript.
# There's one VersionedText for each version of the manuscript, and
# one version of the manuscript for each time the author gets to make
# changes -- minor versions for small changes, like tech checks, and
# major versions for full revisions (after a revise decision).
class VersionedText < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :paper

  belongs_to :submitting_user, class_name: "User"

  scope :version_desc, -> { order('major_version DESC, minor_version DESC') }

  mount_uploader :source, SourceUploader # CarrierWave obj

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

  private

  def creator_name
    submitting_user ? submitting_user.full_name : "(draft)"
  end

  def new_version!(new_major_version, new_minor_version)
    dup.update!(
      major_version: new_major_version,
      minor_version: new_minor_version,
      submitting_user: nil
    )
  end
end
