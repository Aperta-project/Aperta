class AddAuthorsOverlay < CardOverlay
  def add_author author
    find('.btn-xs', text: "Add new").click
    fill_in "First name", with: author[:first_name]
    fill_in "Last name", with: author[:last_name]
    fill_in "Email", with: author[:email]
    fill_in "Affiliation", with: author[:affiliation]
    click_on "done"
  end
end
