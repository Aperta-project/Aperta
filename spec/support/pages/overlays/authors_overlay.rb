# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'support/pages/card_overlay'

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
