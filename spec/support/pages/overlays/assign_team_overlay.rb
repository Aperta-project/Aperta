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

class AssignTeamOverlay < CardOverlay
  def self.visit(assign_team_task, &blk)
    page.visit "/papers/#{assign_team_task.paper.id}/tasks/#{assign_team_task.id}"

    new.tap do |overlay|
      if block_given?
        page.assert_selector(".overlay-container .overlay-body")
        blk.call overlay
        overlay.dismiss
      end
    end
  end

  def assign_role_to_user(role_name, user)
    page.assert_selector(".assign-team-content")

    select2 role_name, from: "Role"

    select2 user.full_name, css: '.assignment-user-input', search: true

    click_button "Assign"
  end

  def unassign_user(user)
    trash_icon = find(".invitation", text: user.full_name).find(".invite-remove")
    trash_icon.click
  end
end
