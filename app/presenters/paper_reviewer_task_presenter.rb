class PaperReviewerTaskPresenter < TaskPresenter
  def data_attributes
    super.merge({
      'reviewers' => select_options_for_users(task.reviewers).to_json,
      'reviewer-ids' => task.reviewer_ids.to_json,
      'refresh-on-close' => true
    })
  end
end
