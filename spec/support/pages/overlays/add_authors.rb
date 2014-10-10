class AddAuthorsOverlay < CardOverlay
  def add_author(author)
    find(".button-secondary", text: "ADD A NEW AUTHOR").click
    group = find('.add-author-form')
    within(group) do
      fill_in_author_form author
      find('.button-secondary', text: "DONE").click
    end
    expect(page).to have_no_css('.add-author-form')
  end

  def edit_author(locator_text, new_info)
    page.execute_script "$('.authors-overlay-item:contains(#{locator_text})').trigger('mouseover')"
    page.execute_script "$('.glyphicon-pencil').click()"
    fill_in_author_form new_info
    click_button 'done'
  end

  def delete_author(locator_text)
    page.execute_script "$('.authors-overlay-item:contains(#{locator_text})').trigger('mouseover')"
    page.execute_script "$('.glyphicon-trash').click()"
    find('.button-secondary', text: "DELETE FOREVER").click
  end

  private
  def fill_in_author_form(author)
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
