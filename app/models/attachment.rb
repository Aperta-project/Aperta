# Attachment represents a generic file/resource. It is intended to be used
# as a base-class.
#
# Note: the subclass(es) should mount the uploader as :file and keep any
# custom processing/version logic with it. Only generic aspects of an
# attachment should be pushed up to this base-class.
class Attachment < ActiveRecord::Base
  include EventStream::Notifiable
  include ProxyableResource

  STATUS_DONE = 'done'

  def self.attachment_uploader(uploader_class)
    mount_uploader :file, uploader_class
  end

  # writes to `token` attr on create
  # `regenerate_token` for new token
  has_secure_token

  belongs_to :owner, polymorphic: true
  belongs_to :paper

  validates :owner, presence: true

  # set_paper is required when creating attachments thru associations
  # where the owner is the paper, it bypasses the owner= method.
  after_initialize :set_paper, if: :new_record?

  def download!(url)
    file.download! url
    self.s3_dir = file.store_dir
    self.file_hash = Digest::SHA256.hexdigest(file.file.read)
  end

  def filename
    self[:file]
  end

  # # This is a hash used for recognizing changes in file contents; if
  # # the file doens't exist, or if we can't connect to amazon, minimal
  # # harm comes from returning nil instead. The error thrown is,
  # # unfortunately, not wrapped by carrierwave.
  # require 'digest'
  # def file_hash
  #   Digest::SHA256.hexdigest((rand(10000) + 1).to_s(16))
  # end

  def done?
    status == STATUS_DONE
  end

  def owner=(new_owner)
    super
    set_paper
  end

  def task
    if owner_type == 'Task'
      owner
    end
  end

  private

  def set_paper
    if owner_type == 'Paper'
      self.paper_id = owner_id
    elsif owner.respond_to?(:paper)
      self.paper = owner.paper
    end
  end
end
