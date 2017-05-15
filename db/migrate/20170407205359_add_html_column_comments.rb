class AddHtmlColumnComments < ActiveRecord::Migration
  def change
    set_column_comment :attachments, :title, "Contains HTML"
    set_column_comment :attachments, :caption, "Contains HTML"
    set_column_comment :comments, :body, "Contains HTML"
    set_column_comment :decisions, :letter, "Contains HTML"
    set_column_comment :discussion_replies, :body, "Contains HTML"
    set_column_comment :invitations, :body, "Contains HTML"
    set_column_comment :invitations, :decline_reason, "Contains HTML"
    set_column_comment :invitations, :reviewer_suggestions, "Contains HTML"
    set_column_comment :papers, :title, "Contains HTML"
    set_column_comment :papers, :abstract, "Contains HTML"
    set_column_comment :related_articles, :linked_title, "Contains HTML"
    set_column_comment :versioned_texts, :text, "Contains HTML"
    set_column_comment :versioned_texts, :original_text, "Contains HTML"
  end
end
