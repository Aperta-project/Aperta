class AssignReviewersOverlay < CardOverlay
  def paper_reviewers=(names)
    names.each do |name|
      select_from_chosen(name, skip_synchronize: false, class: 'reviewers-select')
      # When you select more than 1 new reviewer in rapid succession (like capybara),
      # the event-stream update from the first selection will return
      # before the debounced second selection has posted to the server.
      # If you watch the server logs you'll see the same set of attributes POSTed twice in a row.
      # So we wait before making more selections.
      sleep 0.3 unless name == names.last
    end
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
