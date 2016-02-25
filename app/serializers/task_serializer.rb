# Serializes properties for Ember
# rubocop:disable Style/PredicateName
class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :completed, :body, :old_role, :position,
             :is_metadata_task, :is_submission_task, :is_sidebar_task, :links,
             :phase_id, :assigned_to_me
  has_one :paper, embed: :id

  self.root = :task

  def is_metadata_task
    object.metadata_task?
  end

  def is_submission_task
    object.submission_task?
  end

  def is_sidebar_task
    object.sidebar_task?
  end

  def assigned_to_me
    object.participations.map(&:user).include? scope
  end

  def links
    {
      attachments: task_attachments_path(object),
      comments: task_comments_path(object),
      participations: task_participations_path(object),
      nested_questions: task_nested_questions_path(object),
      nested_question_answers: task_nested_question_answers_path(object),
      snapshots: task_snapshots_path(object)
    }
  end
end
