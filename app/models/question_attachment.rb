# QuestionAttachment is a file attached to an answer for a specific question.
# It will have an owner of NestedQuestionAnswer.
class QuestionAttachment < Attachment
  include Readyable

  after_find :check_ready
  validates :title, value: true, on: :ready
  self.public_resource = true

  def check_ready
    ready?
  end
end
