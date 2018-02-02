class EditorsDiscussionTask < Task
  DEFAULT_TITLE = 'Editor Discussion'.freeze
  DEFAULT_ROLE_HINT = 'admin'.freeze

  def active_model_serializer
    EditorsDiscussionTaskSerializer
  end

  def notify_new_participant(_current_user, participation)
    UserMailer.delay.add_editor_to_editors_discussion participation.user_id, id
  end
end
