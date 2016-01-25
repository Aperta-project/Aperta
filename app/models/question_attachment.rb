class QuestionAttachment < ActiveRecord::Base
  include EventStream::Notifiable
  include ProxyableResource

  belongs_to :nested_question_answer, inverse_of: :attachments

  mount_uploader :attachment, QuestionAttachmentUploader

  # writes to `token` attr on create
  # `regenerate_token` for new token
  has_secure_token

  def filename
    self[:attachment]
  end

  def paper
    nested_question_answer.owner.try(:paper)
  end

  def src
    non_expiring_proxy_url if done?
  end

  private

  def done?
    status == 'done'
  end
end
