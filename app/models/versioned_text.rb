# coding: utf-8
class VersionedText < ActiveRecord::Base
  belongs_to :paper

  belongs_to :submitting_user, class_name: "User"

  scope :version_desc, -> { order('major_version DESC, minor_version DESC') }

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

  def version_string
    date = ""
    date = updated_at.strftime('%b %d, %Y') if updated_at
    "R#{major_version}.#{minor_version} — #{date} #{creator_name}"
  end

  def submitted?
    submitting_user_id.present?
  end

  private

  def creator_name
    submitting_user ? submitting_user.full_name : "(draft)"
  end

  def new_version!(new_major_version, new_minor_version)
    new_version = dup
    new_version.update(major_version: new_major_version,
                       minor_version: new_minor_version,
                       submitting_user: nil)
    new_version.save!
  end
end
