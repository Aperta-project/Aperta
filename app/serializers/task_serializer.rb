class TaskSerializer < ActiveModel::Serializer
  class NestedQuestionSerializer < ActiveModel::Serializer
    attributes :id, :text, :ident
    has_many :children
  end

  attributes :id, :title, :type, :completed, :body, :paper_title, :role, :position,
             :is_metadata_task, :is_submission_task
  has_one :phase, embed: :id
  has_one :paper, embed: :id

  has_many :attachments, embed: :ids, include: true
  has_many :questions, embed: :ids, include: true
  has_many :comments, embed: :ids, include: true
  has_many :participations, embed: :ids, include: true
  has_many :nested_questions, serializer: NestedQuestionSerializer

  self.root = :task

  def paper_title
    object.paper.display_title
  end

  def is_metadata_task
    object.metadata_task?
  end

  def is_submission_task
    object.submission_task?
  end
end
