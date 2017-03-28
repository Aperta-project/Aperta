# Data model that handles the concerns of task comments
class Comment < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :task, inverse_of: :comments
  has_one :paper, through: :task
  belongs_to :commenter, class_name: 'User', inverse_of: :comments
  has_many :comment_looks, inverse_of: :comment, dependent: :destroy
  has_many :participants, through: :task

  validates :task, :body_html, presence: true
  validates_presence_of :commenter

  def created_by?(user)
    commenter_id == user.id
  end

  def notify_mentioned_people
    mentions = UserMentions.new(body_html, commenter).all_users_mentioned
    mentions.each do |mentionee|
      UserMailer.mention_collaborator(self.id, mentionee.id).deliver_later
    end
  end
end
