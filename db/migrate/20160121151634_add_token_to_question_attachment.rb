# Adds a token for providing public non-expiring URLs
# for a question attachment
class AddTokenToQuestionAttachment < ActiveRecord::Migration
  # stands in for model, ensures that regenerate_token is defined
  class QuestionAttachment < ActiveRecord::Base
    def regenerate_token
      update_attributes! token: SecureRandom.hex(24)
    end
  end

  def change
    QuestionAttachment.reset_column_information
    add_column :question_attachments, :token, :string

    reversible do |dir|
      dir.up do
        puts "Adding tokens for #{QuestionAttachment.all.count} previous question_attachments..."
        QuestionAttachment.all.each {|file| file.regenerate_token }
        puts 'Done.'
      end
    end

    add_index :question_attachments, :token, unique: true
  end
end
