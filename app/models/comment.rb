class Comment < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :task, inverse_of: :comments
  belongs_to :commenter, class_name: 'User', inverse_of: :comments
  has_many :comment_looks, inverse_of: :comment, dependent: :destroy
  has_many :participants, through: :task

  validates :task, :body, presence: true
  validates_presence_of :commenter

  after_commit :email_mentioned

  def created_by?(user)
    commenter_id == user.id
  end

  def meta_type
    self.class.name.demodulize
  end

  def has_meta?
    true
  end

  def meta_id
    self.id
  end


  private

  def email_mentioned
    names = Twitter::Extractor.extract_mentioned_screen_names(self.body).uniq - [self.commenter.username]
    people_mentioned = User.where(username: names)

    people_mentioned.each do |mentionee|
      UserMailer.delay.mention_collaborator(self.id, mentionee.id)
    end
  end
end
