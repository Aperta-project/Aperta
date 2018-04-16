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

# Record of an admin editing someone else's content, e.g., reviewer reports
class AdminEdit < ActiveRecord::Base
  include ViewableModel
  belongs_to :reviewer_report
  belongs_to :user

  scope :active, -> { where(active: true) }
  scope :completed, -> { where(active: false) }

  def user_can_view?(check_user)
    check_user.can?(:edit_answers, reviewer_report.paper)
  end

  def self.edit_for(report)
    first_active = report.admin_edits.active.first
    if first_active.present?
      first_active
    else
      report.answers.each do |answer|
        additional = answer.additional_data || {}
        additional[:pending_edit] = answer.value
        answer.update(additional_data: additional)
      end
      report.admin_edits.create(reviewer_report: report, active: true)
    end
  end
end
