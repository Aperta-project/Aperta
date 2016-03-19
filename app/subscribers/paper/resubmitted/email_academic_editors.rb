class Paper::Resubmitted::EmailAcademicEditors
  def self.call(_event_name, event_data)
    paper = event_data[:record]

    paper.academic_editors.each do |editor|
      UserMailer.delay.notify_academic_editor_of_paper_resubmission(
        paper.id,
        editor.id
      )
    end
  end
end
