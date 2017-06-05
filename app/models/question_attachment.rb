# QuestionAttachment is a file attached to an answer for a specific question.
# It will have an owner of NestedQuestionAnswer.
class QuestionAttachment < Attachment
  include Readyable
  validates :filename, value: true, on: :ready
  self.public_resource = true
end
