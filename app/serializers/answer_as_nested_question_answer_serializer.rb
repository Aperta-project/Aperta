# Sends Answers to the frontend in the same shape as NestedQuestionAnswers
class AnswerAsNestedQuestionAnswerSerializer < ActiveModel::Serializer
  root :nested_question_answer
  attributes :id, :value_type, :value, :owner, :nested_question_id
  has_many :attachments, embed: :ids, include: true, root: :question_attachments

  def owner
    { id: object.owner_id, type: object.owner_type.demodulize }
  end

  def nested_question_id
    object.card_content_id
  end

  def value
    if reviewer_report? && can_see_active_edit?
      additional = object.additional_data || {}
      additional["pending_edit"]
    else
      object.value
    end
  end

  def reviewer_report?
    object.owner.class == ReviewerReport
  end

  def can_see_active_edit?
    object.owner.active_admin_edit? && current_user.can?(:edit_answers, object.owner.paper)
  end
end
