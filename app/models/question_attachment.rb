# QuestionAttachment is a file attached to an answer for a specific question.
# It will have an owner of Answer.
class QuestionAttachment < Attachment
  include Readyable
  validates :filename, value: true, on: :ready
  self.public_resource = true

  def card_content
    owner.card_content
  end
end
