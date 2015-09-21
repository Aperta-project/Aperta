class Comment < ActiveRecord::Base
  include EventStream::Notifiable

  belongs_to :task, inverse_of: :comments
  belongs_to :commenter, class_name: 'User', inverse_of: :comments
  has_many :comment_looks, inverse_of: :comment, dependent: :destroy
  has_many :participants, through: :task

  validates :task, :body, presence: true
  validates_presence_of :commenter

  before_save :set_mentions

  def paper
    task.paper
  end

  def created_by?(user)
    commenter_id == user.id
  end

  def notify_mentioned_people
    people_mentioned.each do |mentionee|
      UserMailer.mention_collaborator(self.id, mentionee.id).deliver_later
    end
  end

  private

  # uses the same format as
  # https://dev.twitter.com/overview/api/entities-in-twitter-objects#user_mentions
  def set_mentions
    self.entities = { user_mentions: Twitter::Extractor.extract_mentioned_screen_names_with_indices(body) }
  end

  def people_mentioned
    @people_mentioned ||= User.where(username: mentions_extracted_from_body)
  end

  def mentions_extracted_from_body
    Twitter::Extractor.extract_mentioned_screen_names(body).uniq.map(&:downcase) - [commenter.username.downcase]
  end
end
