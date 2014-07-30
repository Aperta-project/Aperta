class DownloadQuestionAttachmentWorker
  include Sidekiq::Worker

  def perform(question_attachment_id, url)
    question_attachment = QuestionAttachment.find(question_attachment_id)
    question_attachment.tap do |qa|
      qa.attachment.download!(url)
      qa.status = "done"
      qa.save
    end
  end
end
