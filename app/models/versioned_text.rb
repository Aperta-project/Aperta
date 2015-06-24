class VersionedText < ActiveRecord::Base
  belongs_to :paper

  belongs_to :submitting_user, class_name: :user

  before_update :copy, if: :must_copy

  # Called on paper sumbission and resubmission.
  def major_version!
    update!(major_version: (major_version + 1),
            minor_version: 0,
            copy_on_edit: true)
  end

  def must_copy
    copy_on_edit and not copy_on_edit_changed?
  end

  # Make a copy and increment the minor version if the copy_on_edit
  # flag is true.
  def copy
    self.copy_on_edit = false

    old_version = dup
    old_version.text = text_was
    old_version.save

    self.minor_version = minor_version + 1
  end
end
