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

# Represents a row in the table of active invitations for editors,
# reviewers, etc
class ActiveInvitation < PageFragment
  def self.with_header(text)
    el = Capybara.current_session.find('.active-invitations .invitation-item', text: text)
    new(el)
  end

  def self.for_user(user)
    yield with_header(user.full_name)
  end

  def toggle_details
    find('.invitation-item-full-name').click
  end

  def edit(_user)
    find('.invitation-item-header').click
    find('.invitation-item-action-edit').click
  end

  def upload_attachment(file_name)
    upload_file(element_id: 'file',
                file_name: file_name,
                sentinel: proc { InvitationAttachment.count })
    within('.attachment-item') do
      expect(page).to have_css('.file-link', text: file_name)
    end
  end
end
