# This updates the primary key sequence for the attachments table. PostgreSQL
# doesn't automatically set this after INSERTing rows unless nextval() is used.
# This migration is safe to run forwards and backwards and will work if there
# are 0 or more records.
class ResetAttachmentPrimaryKeySequence < ActiveRecord::Migration
  def up
    update_attachments_id_seq
  end

  def down
    update_attachments_id_seq
  end

  private

  def update_attachments_id_seq
    # Use COALESCE in case there are no records in the table, in that case
    # set the sequence ID to 1. For more information see:
    #
    #   https://www.postgresql.org/docs/current/static/functions-conditional.html#FUNCTIONS-COALESCE-NVL-IFNULL
    #
    # Pass in false to setval as its second argument to indicate that this
    # value should be provided the next time nextval() is called. For more
    # information see:
    #
    #   https://www.postgresql.org/docs/9.5/static/functions-sequence.html
    #
    execute <<-SQL
     SELECT setval('attachments_id_seq', coalesce((select max(id)+1 from attachments), 1), false);
    SQL
  end
end
