##
# This model will store the answer given to a piece of
# CardContent.
#
class Answer < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :card_content
  belongs_to :owner, polymorphic: true
  belongs_to :paper

  has_many :attachments, -> { order('id ASC') }, dependent: :destroy, as: :owner, class_name: 'QuestionAttachment'

  validates :card_content, presence: true
  validates :owner, presence: true
  validates :paper, presence: true

  # TODO: Optimize this
  def children
    card_content.children.map do |child|
      Answer.where(owner: owner, card_content: child)
    end
  end

  def task
    if owner.is_a?(Task)
      owner
    elsif owner.respond_to?(:task)
      owner.task
    else
      fail NotImplementedError, <<-ERROR.strip_heredoc
        The owner (#{owner.inspect}) does is not a Task and does not respond to
        #task. This is currently unsupported on #{self.class.name} and if you
        meant it to work you may need to update the implementation.
      ERROR
    end
  end
end
