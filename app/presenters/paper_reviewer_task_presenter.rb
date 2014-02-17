class PaperReviewerTaskPresenter < TaskPresenter
  def data_attributes
    super.merge({
      'reviewers' => select_options_for_users(task.reviewers),
      'reviewerIds' => task.reviewer_ids,
      'refresh-on-close' => true
    })
  end
end
