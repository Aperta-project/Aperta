class MessageTaskPresenter < TaskPresenter
  def data_attributes
    super.merge({
      'message_subject' => task.message_subject,
      'participants' => participant_data,
      'comments' => comment_data,
      'phase_id' => task.phase_id})
  end

  def participant_data
    task.participants.map do |p|
      {id: p.id, name: p.full_name, image_url: "images/profile-no-image.jpg"}
    end
  end

  def comment_data
    task.comments.map do |c|
      {commenter_id: c.commenter_id, body: c.body, created_at: c.created_at}
    end
  end

end
