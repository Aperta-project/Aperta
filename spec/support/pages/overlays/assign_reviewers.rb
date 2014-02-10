class AssignReviewersOverlay < CardOverlay
  def paper_reviewers=(names)
    names.each { |name| select_from_chosen name, from: 'Reviewers' }
  end

  def paper_reviewers
    all('#task_paper_roles_chosen .search-choice').map &:text
  end
end
