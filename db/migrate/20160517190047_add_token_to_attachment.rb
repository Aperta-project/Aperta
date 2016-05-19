class AddTokenToAttachment < ActiveRecord::Migration
  class Attachment < ActiveRecord::Base
    def regenerate_token
      update_attributes! token: SecureRandom.hex(24)
    end
  end

  def change
    Attachment.reset_column_information
    add_column :attachments, :token, :string
    add_index :attachments, :token, unique: true

    reversible do |dir|
      dir.up do
        puts "Adding tokens for #{Attachment.all.count} previous attachments..."
        Attachment.all.each(&:regenerate_token)
        puts 'Done.'
      end
    end
  end
end
