class AddAuthorsOverlay < CardOverlay
  def add_author author
    find('.btn-xs', text: "Add new").click
    fill_in_author_form author
    click_button 'done'
    expect(page).to have_no_css('.add-author-form')
  end

  def edit_author author
    find('.authors-overlay-list li').click
    fill_in_author_form author
    click_button 'done'
  end

  private
  def fill_in_author_form author
    fill_in "First name", with: author[:first_name]
    fill_in "MI", with: author[:middle_initial]
    fill_in "Last name", with: author[:last_name]
    fill_in "Email", with: author[:email]
    fill_in "Title", with: author[:title]
    fill_in "Department", with: author[:department]
    fill_in "Affiliation", with: author[:affiliation]
    fill_in "Secondary Affiliation", with: author[:secondary_affiliation]
  end
end
