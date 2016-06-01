class Paper::Submitted::EmailCreator
  def self.call(_event_name, event_data)
    paper = event_data[:record]
    previous_state = paper.previous_changes[:publishing_state][0]

    case previous_state
    when 'in_revision'
      UserMailer.delay.notify_creator_of_revision_submission(paper.id)
    when 'checking'
      UserMailer.delay.notify_creator_of_check_submission(paper.id)
    else
      if paper.publishing_state == "initially_submitted"
        UserMailer.delay.notify_creator_of_initial_submission(paper.id)
      else
        UserMailer.delay.notify_creator_of_paper_submission(paper.id)
      end
    end
  end
end
