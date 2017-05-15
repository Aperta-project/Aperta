# creates an adhoc attachment block for any adhoc tasks
# that don't alreay have one
module MigrateAttachmentBlocks
  def self.tasks_with_attachments
    ids = AdhocAttachment.distinct(:owner_id).pluck(:owner_id)

    AdHocTask.where(id: ids)
  end

  def self.tasks_to_migrate
    tasks_with_attachments.select do |task|
      task.blocks("attachments").blank?
    end
  end

  def self.add_attachments_block(task)
    task.body << [{ "type" => "attachments", "value" => "Please select a file." }]
    task.save!
  end

  def self.migrate_up
    tasks_to_migrate.each do |task|
      add_attachments_block(task)
    end
  end
end

namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-8477: Add attachment blocks to adhoc cards that lack them.
    DESC
    task migrate_attachment_blocks: :environment do
      MigrateAttachmentBlocks.migrate_up
    end
  end
end
