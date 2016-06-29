class Comment < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :task, inverse_of: :comments
  has_one :paper, through: :task
  belongs_to :commenter, class_name: 'User', inverse_of: :comments
  has_many :comment_looks, inverse_of: :comment, dependent: :destroy
  has_many :participants, through: :task

  validates :task, :body, presence: true
  validates_presence_of :commenter

  def created_by?(user)
    commenter_id == user.id
  end

  def notify_mentioned_people
    people_mentioned = UserMentions.new(body, commenter).all_users_mentioned
    people_mentioned.each do |mentionee|
      UserMailer.mention_collaborator(self.id, mentionee.id).deliver_later
    end
  end
end
