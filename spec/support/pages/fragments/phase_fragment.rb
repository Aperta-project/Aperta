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

require 'support/pages/page_fragment'

class PhaseFragment < PageFragment
  text_assertions :card, '.card'

  def new_card(**params)
    find('a', text: 'ADD NEW CARD').click
    new_card = params[:overlay].launch(session)
    new_card.create(params)
  end

  def remove_card(card_name)
    container = find('.card', text: card_name)
    container.hover
    container.find('.card-remove').click
  end

  def has_remove_icon?
    has_css? '.remove-icon', visible: false
  end

  def has_no_remove_icon?
    has_no_css? '.remove-icon', visible: false
  end

  # add a phase AFTER this phase.
  def add_phase
    container = find('.add-column', visible: false)
    container.hover
    find('.add-column', visible: false).click
  end

  def remove_phase
    retry_stale_element do
      container = find('.column-title')
      container.hover
      remove = find('.remove-icon')
      remove.click
    end
  end

  def rename(new_name)
    field = find('h2')
    field.click
    reversed_name = new_name.reverse
    field.set(reversed_name)
    find('.column-header-update-save').click
  end
end
