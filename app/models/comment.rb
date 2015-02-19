class Comment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :task, inverse_of: :comments
  belongs_to :commenter, class_name: 'User', inverse_of: :comments
  has_many :comment_looks, inverse_of: :comment, dependent: :destroy
  has_many :participants, through: :task

  validates :task, :body, presence: true
  validates_presence_of :commenter

  before_save :escape_body
  before_save :set_mentions
  after_commit :email_mentioned

  def created_by?(user)
    commenter_id == user.id
  end

  # TODO Security? What do you think? Also, should we do this client side too?
  def escape_body
    self.body = ERB::Util.html_escape(body)
  end

  private

  def notifier_payload
    { task_id: task.id, paper_id: task.paper.id }
  end

  def people_mentioned
    names = Twitter::Extractor.extract_mentioned_screen_names(body).uniq - [commenter.username]
    @people_mentioned ||= User.where(username: names)
  end

  # uses the same format as
  # https://dev.twitter.com/overview/api/entities-in-twitter-objects#user_mentions
  def set_mentions
    self.entities = { user_mentions: [] }
    people_mentioned.each do |user|
      handle = '@' + user.username
      first = body.index(handle)
      last = first + handle.length
      indices = { indices: [first, last] }
      self.entities["user_mentions"] << indices
    end
  end

  def email_mentioned
    people_mentioned.each do |mentionee|
      UserMailer.mention_collaborator(self, mentionee).deliver_later
    end
  end
end
