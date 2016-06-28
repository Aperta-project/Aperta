# Attachment represents a generic file/resource. It is intended to be used
# as a base-class.
#
# Note: the subclass(es) should mount the uploader as :file and keep any
# custom processing/version logic with it. Only generic aspects of an
# attachment should be pushed up to this base-class.
class Attachment < ActiveRecord::Base
  include EventStream::Notifiable
  include ProxyableResource
  include Snapshottable

  self.snapshottable = true

  STATUS_DONE = 'done'

  def self.attachment_uploader(uploader_class)
    mount_uploader :file, uploader_class
    skip_callback :save, :after, :remove_previously_stored_file, if: -> { snapshotted? }
  end

  belongs_to :owner, polymorphic: true
  belongs_to :paper
  has_many :snapshots, as: :source, dependent: :destroy

  has_one :resource_token, as: :owner, dependent: :destroy
  delegate :token, to: :resource_token

  validates :owner, presence: true

  # set_paper is required when creating attachments thru associations
  # where the owner is the paper, it bypasses the owner= method.
  after_initialize :set_paper, if: :new_record?

  # This creates the token used by resource proxy to lookup the attachment.
  after_create :create_resource_token

  def download!(url)
    file.download! url
    self.s3_dir = file.store_dir
    self.file_hash = Digest::SHA256.hexdigest(file.file.read)
  end

  def filename
    self[:file]
  end

  def done?
    status == STATUS_DONE
  end

  def owner=(new_owner)
    super
    set_paper
  end

  def snapshot
    snapshots.where(key: snapshot_key)
  end

  def snapshot_key
    file_hash
  end

  def snapshotted?
    if @previous_model_for_file
      @previous_model_for_file.snapshot.present?
    else
      snapshot.present?
    end
  end

  def task
    if owner_type == 'Task'
      owner
    end
  end

  private

  def create_resource_token
    ResourceToken.create owner: self
  end

  def set_paper
    if owner_type == 'Paper'
      self.paper_id = owner_id
    elsif owner.respond_to?(:paper)
      self.paper = owner.paper
    end
  end
end
