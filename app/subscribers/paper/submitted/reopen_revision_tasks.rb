# After a resubmission, we need to reset the Tasks
# for the new round of reviews.
class Paper::Submitted::ReopenRevisionTasks
  def self.call(_, event_data)
    paper = event_data[:record]

    TahiStandardTasks::PaperReviewerTask
      .for_paper(paper)
      .each(&:incomplete!)
    TahiStandardTasks::RegisterDecisionTask
      .for_paper(paper)
      .each(&:incomplete!)
  end
end
