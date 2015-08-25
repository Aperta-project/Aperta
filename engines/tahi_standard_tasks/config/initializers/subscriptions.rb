TahiNotifier.subscribe("paper.submitted") do |payload|
  record_id = payload[:paper_id]

  paper = Paper.find(record_id)

  UserMailer.delay.paper_submission(paper.id)

  if paper.decisions.pending.exists?
    TahiStandardTasks::PaperReviewerTask.for_paper(paper).first.try(:incomplete!)
    TahiStandardTasks::RegisterDecisionTask.for_paper(paper).first.try(:incomplete!)

    if paper.editor
      UserMailer.delay.notify_editor_of_paper_resubmission(paper.id)
    end
  end

  paper.admins.each do |user|
    UserMailer.delay.notify_admin_of_paper_submission(paper.id, user.id)
  end

  SalesforceServices::API.delay.find_or_create_manuscript(paper_id: paper.id)
end
