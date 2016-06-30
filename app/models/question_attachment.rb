# QuestionAttachment is a file attached to an answer for a specific question.
# It will have an owner of NestedQuestionAnswer.
class QuestionAttachment < Attachment
  def download!(url)
    super(url)
    update_attributes!(status: STATUS_DONE)
  end

  def src
    non_expiring_proxy_url if done?
  end
end
