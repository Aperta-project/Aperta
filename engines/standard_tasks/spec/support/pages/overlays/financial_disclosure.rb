class FinancialDisclosureOverlay < CardOverlay
  def received_funding
    find('#received-funding-yes')
  end

  def received_no_funding
    find('#received-funding-no')
  end

  def dataset
    find('.dataset')
  end

  def remove_funder
    dataset.click_link "remove"
  end

  def add_author(first_name, last_name)
    click_button "Add Author"
    fill_in "first-name", with: first_name
    fill_in "last-name", with: last_name
    click_button "Add Author"
  end

  def selected_authors
    find(".chosen-container.chosen-author").all(".search-choice").map(&:text)
  end

  def has_selected_authors?(*names)
    names.all? do |name|
      page.has_css? '.chosen-container.chosen-author .search-choice', text: name
    end
  end
end
