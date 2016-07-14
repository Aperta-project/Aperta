require 'securerandom'

# An S3Migration represents a record of an S3 attachment that needs to
# be migrated from its old +store_dir+ to a new +store_dir+. It assumes the
# old +store_dir+ is cached on the original attachment in a column called
# +s3_dir+.
#
# NOTE: THIS DOES NOT MOVE OR DELETE ANY EXISTING S3 FILES, IT JUST COPIES THEM
class S3Migration < ActiveRecord::Base
  # UploaderOverrides updates the CarrierWave uploaders
  # that we are intending to migration files from. We do this at the class
  # and not instance level because CarrierWave caches a lot of stuff
  # internally once you instantiate an instance of an uploader. This
  # allows us to avoid having to deal with cached information as long as
  # this mixin is included before any specific instances are loaded.
  module UploaderOverrides
    def self.included(base)
      base.class_eval do
        # Whatever the current +store_dir+ is considered the modern or "new"
        # directory. It's where we want files to end up.
        alias_method :new_store_dir, :store_dir

        # Override +store_dir+ to point to a cached +s3_dir+ since this is
        # where the old store_dir location was stored.
        def store_dir
          model.s3_dir
        end

        # Add +new_store_path+ to return the S3 key for where we want the
        # file to go.
        def new_store_path(for_file=filename)
          File.join([generate_new_store_dir, full_filename(for_file)].compact)
        end
      end
    end
  end

  include AASM

  def self.migrate!
    ready.all.each do |migration|
      puts "Performing migration: #{migration.inspect}"
      migration.migrate!
    end
  end

  scope :ready, ->{ where(state: 'ready') }

  belongs_to :attachment, polymorphic: true

  aasm column: :state, requires_new_transaction: false do
    state :ready, initial: true
    state :in_progress
    state :completed
    state :failed

    event(:migrate, after: [:perform_migration]) do
      transitions from: :ready,
                  to: :in_progress

    end

    event(:completed) do
      transitions from: :in_progress,
                  to: :completed
    end

    event(:failed) do
      transitions from: :in_progress,
                  to: :failed
    end

    event(:remigrate, after: [:perform_migration]) do
      transitions from: [:failed, :completed, :in_progress],
                  to: :in_progress
    end
  end

  def s3object
    @response ||= storage.get_object(
      ENV['S3_BUCKET'],
      source_url
    )
  end

  private

  # CarrierWave caches its file too agressivly. We retrieve a fresh attachment
  # instance to ensure we have the most up-to-date copy of the file.
  def retrieve_fresh_attachment
    Attachment.find(attachment.id)
  end

  def add_urls_to_resource_tokens
    fresh_attachment = retrieve_fresh_attachment
    fresh_attachment.ensure_resource_token_has_urls!(fresh_attachment.file)
  end

  def recreate_versions!
    retrieve_fresh_attachment.file.recreate_versions!
  end

  def perform_migration
    # There is a lot of orphaned data (at least on staging) so this is to
    # ignore it.
    if attachment.is_a?(Figure)
      if attachment.paper.nil?
        puts "Paper is nil. Attachment (id=#{attachment.id}) is an orphan. :("
        return
      end
    elsif attachment.owner.nil? && attachment.paper.nil?
      puts "Owner and Paper are nil. Attachment (id=#{attachment.id}) is an orphan. :("
      return
    end

    previous_file_hash = attachment.previous_file_hash || s3object.data[:headers]['ETag'].gsub('"', '')
    new_file_hash = Digest::SHA256.hexdigest(s3object.data[:body])
    # new_file_hash = SecureRandom.uuid # <-- this value is used for manual testing

    # Do not modify the file hashes if we're migrating a version (e.g detail,
    # preview, etc.) as they  use their parent (CarrierWave Uploader object)
    # attachment's file hash. Otherwise, each version of an attachment will end
    # up in its own "directory" on S3.
    unless version?
      # do not use update_attributes because we only want to save these
      # columns, and not trigger any carrierwave functionality at this point.
      attachment.update_column :previous_file_hash, previous_file_hash
      attachment.update_column :file_hash, new_file_hash
    end


    # only backfill an attachment snapshot if we found an existing
    # task snapshot for this attachment
    task_snapshot = find_and_update_task_snapshot(previous_file_hash, new_file_hash)
    if task_snapshot
      SnapshotService.new(attachment.paper).snapshot!(attachment)
    end

    destination_url = attachment.file.new_store_path(File.basename(source_url))
    update_attributes!(
      destination_url: destination_url
    )

    # Move the old file to the new S3 location
    if source_url == destination_url
      msg = "Skipping S3 migration on id=#{id} because source_url is the same as destination_url."
      puts msg
      Rails.logger.info msg
    else
      storage.copy_object(
        ENV['S3_BUCKET'],
        source_url,
        ENV['S3_BUCKET'],
        destination_url
      )
      attachment.update_column :s3_dir, attachment.file.generate_new_store_dir
    end
    add_urls_to_resource_tokens
    recreate_versions! if attachment.is_a? QuestionAttachment
    completed!
  rescue Exception => ex
    update_attributes!(
      error_message: ex.message,
      error_backtrace: ex.backtrace.join("\n"),
      errored_at: Time.zone.now
    )
    failed!
    msg = "Failed S3 migration on #{self.inspect}. See S3Migration.find(#{id}) for more information."
    STDERR.puts msg, ex.message, ex.backtrace, ""
    Rails.logger.error msg
  end

  def storage
    @storage ||= Fog::Storage.new(
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION']
    )
  end

  # Finds the first Snapshot that makes reference of the previous_file_hash,
  # updating that reference to point to the new_file_hash, then returning
  # that Snapshot. Returns nil if not snapshot.
  def find_and_update_task_snapshot(previous_file_hash, new_file_hash)
    ::Snapshot.all.each do |snapshot|
      child = find_child_with_file_hash previous_file_hash, snapshot.contents
      if child
        # update snapshot to use new_file_hash instead of the previous_file_hash
        child['value'] = new_file_hash
        child.save!
        snapshot
      end
    end
  end

  # This is helper method that is used to walk the the 'children' inside of
  # a given node (Hash data structure) look for the first file_hash child
  # that matches the given file_hash. Recursively calls itself until a
  # node is found, otherwise returns nil.
  def find_child_with_file_hash(file_hash, node)
    if node['name'] == 'file_hash' && node['value'] == file_hash
      node
    elsif node['children']
      node['children'].detect do |node|
        find_child_with_file_hash file_hash, node
      end
    else
      nil
    end
  end
end
