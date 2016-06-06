class Paper::Submitted::EmailCreator
  def self.call(_event_name, event_data)
    paper = event_data[:record]
    previous_state = paper.previous_changes[:publishing_state][0]

    if previous_state == 'in_revision'
      UserMailer.delay.notify_creator_of_revision_submission(paper.id)
    elsif previous_state == 'checking'
      UserMailer.delay.notify_creator_of_check_submission(paper.id)
    elsif paper.publishing_state == "initially_submitted"
      UserMailer.delay.notify_creator_of_initial_submission(paper.id)
    else
      UserMailer.delay.notify_creator_of_paper_submission(paper.id)
    end
  end
end
