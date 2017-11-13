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

  def activities
    Activity.feed_for('workflow', object).map do |f|
      {
        activity_key: f.activity_key,
        full_name: f.user.full_name,
        created_at: f.created_at
      }
    end
  end
end
