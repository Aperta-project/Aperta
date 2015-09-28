class Paper::Resubmitted::ReopenRevisionTasks

  # after a resubmission, we need to reset the Tasks for the new round of reviews.
  #
  def self.call(event_name, event_data)
    paper = event_data[:paper]

    TahiStandardTasks::ReviewerReportTask.for_paper(paper).first.try(:incomplete!)
    TahiStandardTasks::PaperReviewerTask.for_paper(paper).first.try(:incomplete!)
    TahiStandardTasks::RegisterDecisionTask.for_paper(paper).first.try(:incomplete!)
  end

end
