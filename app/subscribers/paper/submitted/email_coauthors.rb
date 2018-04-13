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

class Paper::Submitted::EmailCoauthors
  def self.call(_event_name, event_data)
    paper = event_data[:record]
    previous_state = paper.previous_changes[:publishing_state][0]

    return unless paper.journal.setting("coauthor_confirmation_enabled").value

    if previous_state == 'unsubmitted' || previous_state == 'invited_for_full_submission'
      coauthors = paper.all_authors.reject { |author| author.try(:email) == paper.creator.email }
      coauthors.each do |coauthor|
        UserMailer.delay.notify_coauthor_of_paper_submission(paper.id, coauthor.id, coauthor.class.name)
      end
    end
  end
end
