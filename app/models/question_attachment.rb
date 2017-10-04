# QuestionAttachment is a file attached to an answer for a specific question.
# It will have an owner of Answer.
class QuestionAttachment < Attachment
  include Readyable
  validates :filename, value: true, on: :ready

  self.public_resource = true

  def self.cover_letter
    joins(<<-SQL
  INNER JOIN answers ON answers.id = attachments.owner_id
  INNER JOIN card_contents on card_contents.id = answers.card_content_id
  SQL
         ).where(card_contents: { ident: "cover_letter--attachment" })
  end

  def card_content
    owner.card_content
  end

  def answer_blank?
    filename.nil?
  end
end
