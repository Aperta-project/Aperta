class Paper::Submitted::EmailAdmins

  def self.call(_event_name, event_data)
    paper = event_data[:record]
    return if paper.latest_decision_rescinded?

    paper.admins.each do |user|
      UserMailer.delay.notify_admin_of_paper_submission(paper.id, user.id)
    end
  end

end
