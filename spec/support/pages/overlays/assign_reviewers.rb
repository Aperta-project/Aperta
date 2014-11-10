class AssignReviewersOverlay < CardOverlay
  text_assertions :reviewer, '.reviewer-select2 .select2-search-choice'
  def paper_reviewers=(reviewers)
    reviewers.each do |reviewer|
      session.has_no_css?('#delayedSave', visible: false)
      pick_from_select2_single(reviewer.username, reviewer.full_name, class: 'reviewer-select2')
    end
  end

  def paper_reviewers
    all('.reviewer-select2 .select2-search-choice').map &:text
  end

  def has_reviewers?(*reviewers)
    reviewers.all? do |reviewer|
      has_reviewer? reviewer.full_name
    end
  end

  def remove_all_paper_reviewers!
    all('a.select2-search-choice-close').each &:click
  end
end
