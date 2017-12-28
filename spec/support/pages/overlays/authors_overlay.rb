class AuthorsOverlay < CardOverlay
  def add_author(author)
    find(".button-primary", text: "ADD A NEW AUTHOR").click
    group = find('.add-author-form')
    within(group) do
      fill_in_author_form author
      find('.button-secondary', text: "DONE").click
    end
    expect(page).to have_no_css('.add-author-form')
  end

  def edit_author(locator_text, new_info)
    page.execute_script "$('.authors-overlay-item:contains(#{locator_text})').trigger('mouseover')"
    page.execute_script "$('.authors-overlay-item--actions .fa-pencil').click()"
    fill_in_author_form new_info
    click_button 'done'
  end

  def delete_author(locator_text)
    page.execute_script "$('.authors-overlay-item:contains(#{locator_text})').trigger('mouseover')"
    page.execute_script "$('.fa-trash').click()"
    find('.button-secondary', text: "DELETE FOREVER").click
  end

  private

  def fill_in_author_form(author)
    page.find(".add-author-form input.author-first").set(author[:first_name])
    page.find(".add-author-form input.author-middle").set(author[:middle_initial])
    page.find(".add-author-form input.author-last").set(author[:last_name])
    page.find(".add-author-form input.author-email").set(author[:email])
    page.find(".add-author-form input.author-title").set(author[:title])
    page.find(".add-author-form input.author-department").set(author[:department])
  end
end
