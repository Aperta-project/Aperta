class AssignReviewersOverlay < CardOverlay
  def paper_reviewers=(names)
    names.each { |name| select_from_chosen name, from: 'Reviewers' }
  end

  def paper_reviewers
    reviewer_ids = find('#task_paper_roles', visible: false).value
    all('#task_paper_roles option', visible: false).select do |o|
      reviewer_ids.include? o.value
    end.map &:text
  end
end
