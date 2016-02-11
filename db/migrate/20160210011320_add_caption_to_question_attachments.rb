# Add caption field so QuestionAttachment to mimic Attachment
class AddCaptionToQuestionAttachments < ActiveRecord::Migration
  def change
    add_column :question_attachments, :caption, :string
  end
end
