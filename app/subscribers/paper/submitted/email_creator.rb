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

class Paper::Submitted::EmailCreator
  def self.call(_event_name, event_data)
    paper = event_data[:record]
    return if paper.latest_decision_rescinded?

    previous_state = paper.previous_changes[:publishing_state][0]

    if previous_state == 'in_revision'
      UserMailer.delay.notify_creator_of_revision_submission(paper.id)
    elsif previous_state == 'checking'
      UserMailer.delay.notify_creator_of_check_submission(paper.id)
    elsif paper.publishing_state == "initially_submitted"
      UserMailer.delay.notify_creator_of_initial_submission(paper.id)
    else
      UserMailer.delay.notify_creator_of_paper_submission(paper.id)
    end
  end
end
