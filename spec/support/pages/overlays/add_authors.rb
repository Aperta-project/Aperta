class AddAuthorsOverlay < CardOverlay
  def add_author author
    find('.btn-xs', text: "Add new").click
    fill_in "First name", with: author[:first_name]
    fill_in "MI", with: author[:middle_initial]
    fill_in "Last name", with: author[:last_name]
    fill_in "Email", with: author[:email]
    fill_in "Title", with: author[:title]
    fill_in "Department", with: author[:department]
    fill_in "Affiliation", with: author[:affiliation]
    fill_in "Secondary Affiliation", with: author[:secondary_affiliation]
    find('.add-author-form button.secondary-button').click
    expect(page).to have_no_css('.add-author-form')
  end
end
