class CorrespondenceSerializer < ActiveModel::Serializer
  require 'link_sanitizer'
  attributes :id, :date, :subject, :recipient, :sender, :body,
             :recipients, :sent_at, :external, :description, :status,
             :cc, :bcc, :manuscript_version, :manuscript_status, :activities,
             :delete_reason

  has_many :attachments, embed: :ids, include: true, root: :correspondence_attachments

  def date
    object.updated_at
  end

  def recipient
    object.recipients
  end

  def body
    LinkSanitizer.sanitize(object.body.presence || object.raw_source)
  end

  def deleted?
    object.status == 'deleted'
  end

  def attributes(*args)
    return super unless deleted?
    super.except(:subject, :sender, :recipient, :recipients, :body, :description, :cc, :bcc)
  end

  def attachments
    object.attachments unless deleted?
    []
  end

  def delete_reason
    object.additional_context["delete_reason"] if deleted?
  end
end
