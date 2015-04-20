TahiNotifier.subscribe("paper.submitted") do |subscription_name, payload|
  record_id = payload[:paper_id]

  paper = Paper.find(record_id)

  if paper.decisions.pending.exists?
    TahiStandardTasks::PaperReviewerTask.for_paper(paper).first.try(:incomplete!)
    TahiStandardTasks::RegisterDecisionTask.for_paper(paper).first.try(:incomplete!)

    if paper.editor
      UserMailer.delay.notify_editor_of_paper_resubmission(paper.id)
    end
  end
end
