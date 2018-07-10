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

class AddCollaboratorsOverlay < CardOverlay
  text_assertions :collaborator, ".collaborator .name"

  def add_collaborators(*users)
    users.map(&:full_name).each do |name|
      select2 name, css: '.collaborator-select', search: true
    end
  end

  def has_collaborators?(*collaborators)
    collaborators.all? do |collaborator|
      has_collaborator? collaborator.full_name
    end
  end

  def has_no_collaborators?
    has_no_css?(".collaborator")
  end

  def remove_collaborators(*collaborators)
    collaborators.map(&:full_name).each do |name|
      node = first('.collaborator .name', text: name)
      node.first('.delete-button').click
    end
  end

  def save
    find('.button-primary', text: 'SAVE').click
    expect(self).not_to have_css('.show-collaborators-overlay')
  end
end
