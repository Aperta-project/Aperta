class DiscussionReply < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include EventStream::Notifiable
  include ActionView::Helpers::SanitizeHelper

  belongs_to :discussion_topic, inverse_of: :discussion_replies
  belongs_to :replier, inverse_of: :discussion_replies, class_name: 'User'
  has_many :notifications, as: :target

  before_create :process_at_mentions!

  alias_attribute :body_html, :body

  def strip_body_html
    strip_tags(body_html)
  end

  def process_at_mentions!
    self.body_html = user_mentions.decorated_mentions
  end

  def user_mentions
    @user_mentions ||=
      UserMentions.new(body_html, replier, permission_object: discussion_topic)
  end

  def sanitized_body
    formatted = simple_format(strip_tags(body_html))

    UserMentions
      .new(formatted, replier, permission_object: discussion_topic)
      .decorated_mentions
  end
end
