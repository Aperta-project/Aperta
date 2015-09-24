class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :completed, :body, :role, :position,
             :is_metadata_task, :is_submission_task, :links,
             :phase_id, :assigned_to_me, :paper_id

  has_many :nested_questions, serializer: NestedQuestionSerializer, embed: :ids, include: true
  has_many :nested_question_answers, serializer: NestedQuestionAnswerSerializer, embed: :ids, include: true

  self.root = :task

  def paper_title
    object.paper.display_title(sanitized: false)
  end

  def is_metadata_task
    object.metadata_task?
  end

  def is_submission_task
    object.submission_task?
  end

  def assigned_to_me
    user = scope.presence
    if user
      object.participations.map(&:user_id).include? user.id
    else
      false
    end
  end

  def links
    {
      attachments: task_attachments_path(object),
      comments: task_comments_path(object),
      participations: task_participations_path(object),
    }
  end
end
