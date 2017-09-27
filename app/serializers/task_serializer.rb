# Serializes properties for Ember
# rubocop:disable Style/PredicateName
class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :type, :completed, :body, :position,
             :is_metadata_task, :is_submission_task, :is_snapshot_task,
             :links, :phase_id, :assigned_to_me, :owner_type_for_answer,
             :card_version_id, :paper_id, :is_workflow_only_task,
             :display_status, :viewable, :assigned_user_id

  self.root = :task

  def viewable
    scope.can?(:view, object)
  end

  def is_metadata_task
    object.metadata_task?
  end

  def is_submission_task
    object.submission_task?
  end

  def is_snapshot_task
    object.snapshottable?
  end

  def is_workflow_only_task
    object.latest_published_card_version.try(:workflow_display_only?) || false
  end

  def assigned_to_me
    # Reviewers are not participants on their own task
    if object.reviewer.blank?
      object.participations.map(&:user).include? scope
    else
      object.reviewer == scope
    end
  end

  def links
    {
      attachments: task_attachments_path(object),
      comments: task_comments_path(object),
      participations: task_participations_path(object),
      nested_questions: task_nested_questions_path(object),
      answers: answers_for_owner_path(owner_id: object.id, owner_type: object.class.name.underscore),
      nested_question_answers: task_nested_question_answers_path(object),
      snapshots: task_snapshots_path(object)
    }
  end
end
