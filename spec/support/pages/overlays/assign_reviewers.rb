class AssignReviewersOverlay < CardOverlay
  def paper_reviewers=(names)
    names.each { |name| select_from_chosen name, class: 'reviewers-select' }
  end

  def paper_reviewers
    all('.reviewers-select .search-choice').map &:text
  end
end
