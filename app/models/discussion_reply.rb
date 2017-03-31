class DiscussionReply < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  include EventStream::Notifiable

  belongs_to :discussion_topic, inverse_of: :discussion_replies
  belongs_to :replier, inverse_of: :discussion_replies, class_name: 'User'
  has_many :notifications, as: :target

  before_create :process_at_mentions!

  alias_attribute :body_html, :body
  def process_at_mentions!
    self.body = user_mentions.decorated_mentions
  end

  def user_mentions
    @user_mentions ||=
      UserMentions.new(body, replier, permission_object: discussion_topic)
  end

  def sanitized_body
    formatted = simple_format(strip_tags(body))

    UserMentions
      .new(formatted, replier, permission_object: discussion_topic)
      .decorated_mentions
  end
end
