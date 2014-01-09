class AssignReviewerOverlay < CardOverlay
  def paper_reviewers=(names)
    names.each { |name| select_from_chosen name, from: 'Reviewers' }
  end

  def paper_reviewers
    all('#task_paper_roles option[selected]', visible: false).map(&:text)
  end
end
