class CorrespondenceSerializer < ActiveModel::Serializer
  require 'link_sanitizer'
  attributes :id, :date, :subject, :recipient, :sender, :body,
             :recipients, :sent_at, :external, :description,
             :cc, :bcc, :manuscript_version, :manuscript_status, :activities

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
end
