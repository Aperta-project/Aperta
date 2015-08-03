class RemoveInvalidPublishingState < ActiveRecord::Migration
  def up
    execute "UPDATE papers SET publishing_state='checking' WHERE publishing_state='in_minor_revision';"
  end

  def down
    execute "UPDATE papers SET publishing_state='in_minor_revision' WHERE publishing_state='checking';"
  end
end

