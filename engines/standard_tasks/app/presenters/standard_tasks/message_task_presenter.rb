module StandardTasks
  class MessageTaskPresenter < TaskPresenter
    def data_attributes
      super.merge({
        'messageSubject' => task.message_subject,
        'participants' => participant_data,
        'comments' => comment_data,
        'phase_id' => task.phase_id})
    end

    def participant_data
      task.participants.map do |p|
        {id: p.id, fullName: p.full_name, imageUrl: "/images/profile-no-image.jpg"}
      end
    end

    def comment_data
      task.comments.map do |c|
        {commenterId: c.commenter_id, body: c.body, createdAt: c.created_at}
      end
    end

  end
end
