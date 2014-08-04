class AssignReviewersOverlay < CardOverlay
  def paper_reviewers=(names)
    names.each { |name| select_from_chosen name, skip_synchronize: true, class: 'reviewers-select' }
  end

  def paper_reviewers
    all('.reviewers-select .search-choice').map &:text
  end

  def has_reviewers?(*reviewers)
    # wait for the element
    find_all '.reviewers-select .search-choice'
    reviewers.all? do |reviewer|
      page.has_css? '.reviewers-select .search-choice', text: reviewer.full_name
    end
  end

  def remove_all_paper_reviewers!
    all('a.search-choice-close').each &:click
  end
end
