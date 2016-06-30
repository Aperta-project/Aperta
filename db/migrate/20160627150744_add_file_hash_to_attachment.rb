# +file_hash+ is being added to attachments so we can uniquely track the content
# of a file. It supports attachment versioning and diff'ing.
#
# +previous_file_hash+ is being added to support migrating existing attachments
# from the file hash that is computed today (Amazon S3's E-Tag value) to
# our own file hashing scheme that Aperta owns.
class AddFileHashToAttachment < ActiveRecord::Migration
  def change
    add_column :attachments, :file_hash, :string
    add_column :attachments, :previous_file_hash, :string
  end
end
