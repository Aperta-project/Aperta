class Paper::Resubmitted::EmailEditor
  def self.call(_event_name, event_data)
    paper = event_data[:record]

    if paper.academic_editor
      UserMailer.delay.notify_editor_of_paper_resubmission(paper.id)
    end
  end
end
