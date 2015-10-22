class Paper::Submitted::EmailCreator

  def self.call(_event_name, event_data)
    paper = event_data[:record]

    UserMailer.delay.notify_creator_of_paper_submission(paper.id)
  end

end
