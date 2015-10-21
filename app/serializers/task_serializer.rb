class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :completed, :body, :paper_title, :role, :position,
             :is_metadata_task, :is_submission_task
  has_one :phase, embed: :id
  has_one :paper, embed: :id

  has_many :attachments, embed: :ids, include: true
  has_many :comments, embed: :ids, include: true
  has_many :participations, embed: :ids, include: true
  has_many :nested_questions, serializer: NestedQuestionSerializer, embed: :ids, include: true
  has_many :nested_question_answers, serializer: NestedQuestionAnswerSerializer, embed: :ids, include: true

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
