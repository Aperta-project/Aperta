# Attachment represents a generic file/resource. It is intended to be used
# as a base-class.
#
# Attachment mounts its file using the AttachmentUploader class, which has
# provisions for creating preview and detail versions of uploaded images.
# For the time being any subclass of Attachment will use the AttachmentUploader
# as well.
class Attachment < ActiveRecord::Base
  include EventStream::Notifiable
  include ProxyableResource
  include Snapshottable

  IMAGE_TYPES = %w(jpg jpeg tiff tif gif png eps tif).freeze

  STATUSES = {
    processing: 'processing'.freeze,
    error: 'error'.freeze,
    done: 'done'.freeze
  }.freeze
  STATUS_PROCESSING = STATUSES[:processing]
  STATUS_ERROR = STATUSES[:error]
  STATUS_DONE = STATUSES[:done]

  class_attribute :public_resource

  scope :processing, -> { where(status: STATUS_PROCESSING) }
  scope :error, -> { where(status: STATUS_ERROR) }
  scope :done, -> { where(status: STATUS_DONE) }
  scope :unknown, -> { where.not(status: STATUSES.values) }

  def public_resource
    value = @public_resource
    value = self.class.public_resource if @public_resource.nil?

    if value.nil?
      raise NotImplementedError, <<-ERROR.strip_heredoc
        #{self.class.name} did not declare whether it was a public or private
        resource. Please set this after careful consideration in
        #{self.class.name}. Here's what that might need to look like:

            self.public_resource = true|false
      ERROR
    end

    value
  end

  self.snapshottable = true

  # +snapshottable_uploader+ will prevent carrierwave from removing a
  # mounted file/attachment if the including model has been snapshotted.
  def self.mount_uploader(mounted_as, uploader_class)
    super mounted_as, uploader_class
    carrierwave_removal_method_on_save = "remove_previously_stored_#{mounted_as}".to_sym
    skip_callback :save, :after, carrierwave_removal_method_on_save, if: -> { keep_file_when_replaced? }

    carrierwave_removal_method_on_destroy = "remove_#{mounted_as}!".to_sym
    skip_callback :commit, :after, carrierwave_removal_method_on_destroy, if: -> { keep_file_when_replaced? }
  end

  mount_uploader :file, AttachmentUploader

  def self.authenticated_url_for_key(key)
    uploader = new.file
    CarrierWave::Storage::Fog::File.new(
      uploader,
      uploader.send(:storage),
      key
    ).url
  end

  belongs_to :uploaded_by, class_name: "User"
  belongs_to :owner, polymorphic: true
  belongs_to :paper

  validates :owner, presence: true

  # set_paper is required when creating attachments thru associations
  # where the owner is the paper, it bypasses the owner= method.
  after_initialize :set_paper, if: :new_record?

  def keep_file_when_replaced?
    snapshotted?
  end

  def cancel_download
    case status
    when STATUS_PROCESSING
      # delete the attachment and let sidekiq deal with it
      #
      # sidekiq still running
      destroy
    when STATUS_ERROR
      # clean up from exception in sidekiq
      #
      # sidekiq not running due to exception
      destroy
    when STATUS_DONE
      # sidekiq completely done, two ships passing in the night
      # no-op
    end
  end

  # rubocop:disable Metrics/AbcSize
  def download!(url, uploaded_by: nil)
    # Wrap this in a transaction so the ActiveRecord after_commit lifecycle
    # event isn't fired until the transaction completes and all of the work is
    # finished.

    # Store the url and uploaded_by now in case of any failures
    update_column :pending_url, url
    update_column :uploaded_by_id, uploaded_by.try(:id)

    Attachment.transaction do
      @downloading = true
      file.download! url

      self.file_hash = Digest::SHA256.hexdigest(file.file.read)
      self.s3_dir = file.generate_new_store_dir
      self.title_html = build_title

      # Using save! instead of update_attributes because the above are not the
      # only attributes that have been updated. We want to persist all changes
      save!(validate: false)
      create_resource_token!(file) if public_resource

      # Do not mark as done until all of the steps that go into downloading a
      # file, creating resource tokens, etc are completed. This is to avoid
      # other parts of the system thinking the attachment is done downloading
      # before it's fully realized/usable.
      update_column :status, STATUS_DONE

      @downloading = false
      on_download_complete
    end
  rescue Exception => ex
    update_columns(status: STATUS_ERROR,
                   error_message: ex.message,
                   error_backtrace: ex.backtrace.join("\n"),
                   errored_at: Time.zone.now)
    on_download_failed(ex)
  ensure
    @downloading = false
  end
  # rubocop:enable Metrics/AbcSize

  def public_url(*args)
    non_expiring_proxy_url(*args) if public_resource
  end

  def downloading?
    @downloading
  end

  def on_download_complete
    # no-op. Sweet hook method to add in a subclass to perform actions after an
    # attachment is downloaded.
  end

  def on_download_failed(exception)
    raise exception
  end

  def url(*args)
    file.url(*args)
  end

  def filename
    self[:file]
  end

  def did_file_change?
    # check to see if the file changed in a way that recognizes reverting to
    # an old MS version (pre file_hash)
    did_file_change_pre_file_hash = file_hash.blank? &&
      (changes.include?('file') || previous_changes.include?('file'))

    # This is the modern way
    did_file_change = file_hash.present? &&
      (changes.include?('file_hash') || previous_changes.include?('file_hash'))

    did_file_change_pre_file_hash || did_file_change
  end

  # This returns the a local File object referencing the manuscript source
  # file. It will download the file from the a remote location if it is not
  # already locally cached.
  def to_file
    file.download!(url) unless file.cached?
    File.new(file.path)
  end

  def done?
    status == STATUS_DONE
  end

  def owner=(new_owner)
    super
    set_paper
  end

  def snapshot_key
    file.current_path
  end

  def snapshotted?
    if @previous_model_for_file
      @previous_model_for_file.snapshot.present?
    else
      snapshot.present?
    end
  end

  # in this case, owner_type is referring to the Table name of the owner,
  # so we still want to use the base 'Task' instead of a specific subclass
  def task
    owner if owner_type == 'Task'
  end

  def invitation
    owner if owner_type == 'Invitation'
  end

  # These methods were pulled up from Attachment subclasses
  def src
    return unless done?
    return unless public_resource
    non_expiring_proxy_url
  end

  def access_details
    { filename: filename, alt: alt, id: id, src: src }
  end

  def detail_src(**opts)
    return unless image?
    return unless done?
    return unless public_resource

    non_expiring_proxy_url(version: :detail, **opts)
  end

  def preview_src
    return unless image?
    return unless done?
    return unless public_resource

    non_expiring_proxy_url(version: :preview)
  end

  def image?
    file_path = self['file']
    return false if file_path.blank?
    AttachmentUploader.image?(file_path)
  end

  protected

  def build_title
    title_html || file.filename
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
