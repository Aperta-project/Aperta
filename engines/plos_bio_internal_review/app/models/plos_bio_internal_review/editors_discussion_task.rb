class PlosBioInternalReview::EditorsDiscussionTask < Task
  DEFAULT_TITLE = 'Editor Discussion'.freeze

  def active_model_serializer
    PlosBioInternalReview::EditorsDiscussionTaskSerializer
  end

  def notify_new_participant(_current_user, participation)
    UserMailer.delay.add_editor_to_editors_discussion participation.user_id, id
  end
end
