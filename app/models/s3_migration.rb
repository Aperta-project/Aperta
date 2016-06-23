# An S3Migration represents a record of an S3 attachment that needs to
# be migrated from its old +store_dir+ to a new +store_dir+. It assumes the
# old +store_dir+ is cached on the original attachment in a column called
# +s3_dir+.
class S3Migration < ActiveRecord::Base
  # UploaderOverrides updates the CarrierWave uploaders
  # that we are intending to migration files from. We do this at the class
  # and not instance level because CarrierWave caches a lot of stuff
  # internally once you instantiate an instance of an uploader. This
  # allows us to avoid having to deal with cached information as long as
  # this mixin is included before any speific instances are loaded.
  module UploaderOverrides
    def self.included(base)
      base.class_eval do
        # Whatever the current +store_dir+ is considered the modern or "new"
        # directory. It's where we want files to end up.
        alias_method :new_store_dir, :store_dir

        # Override +store_dir+ to point to a cached +s3_dir+ since this is
        # where the old store_dir location will be stored.
        def store_dir
          model.s3_dir
        end

        # Add +new_store_path+ to return the S3 key for where we want the
        # file to go.
        def new_store_path(for_file=filename)
          File.join([new_store_dir, full_filename(for_file)].compact)
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
    response ||= storage.get_object(
      ENV['S3_BUCKET'],
      source_url
    )
  end

  private

  def storage
    @storage ||= Fog::Storage.new(
      provider: 'AWS',
      aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: ENV['AWS_REGION']
    )
  end

  def perform_migration
    previous_file_hash = attachment.previous_file_hash || s3object.data[:headers]['ETag'].gsub('"', '')
    new_file_hash = Digest::SHA256.hexdigest(s3object.data[:body])

    # Do not modify the file hashes if we're migrating a version as they
    # use their parent attachment(s) file hash. Otherwise, each version of
    # an attachment will end up in its own "directory" on S3.
    unless version?
      attachment.update_attributes!(
        previous_file_hash: previous_file_hash,
        file_hash: new_file_hash,
      )
    end

    destination_url = attachment.file.new_store_path(File.basename(source_url))
    binding.pry
    update_attributes!(
      destination_url: attachment.file.store_path(File.basename(source_url))
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
      attachment.update_column :s3_dir, attachment.file.store_dir
    end
    completed!
  rescue Exception => ex
    update_attributes(
      error_message: ex.message,
      error_backtrace: ex.backtrace.join("\n"),
      errored_at: Time.zone.now
    )
    failed!
    msg = "Failed S3 migration on #{self.inspect}. See S3Migration.find(#{id}) for more information."
    STDERR.puts msg
    Rails.logger.error msg
  end
end
