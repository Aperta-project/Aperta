class PlosBio::EditorsDiscussionTask < Task
  register_task default_title: "Editor Discussion", default_role: 'admin'

  def active_model_serializer
    PlosBio::EditorsDiscussionTaskSerializer
  end

  def notify_new_participant current_user, participation
    UserMailer.delay.add_editor_to_editors_discussion participation.user_id, id
  end
end
