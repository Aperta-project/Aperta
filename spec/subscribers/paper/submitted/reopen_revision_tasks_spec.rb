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

require 'rails_helper'

describe Paper::Submitted::ReopenRevisionTasks do
  include EventStreamMatchers

  let(:mailer) { mock_delayed_class(UserMailer) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:paper_reviewer_task) do
    FactoryGirl.create(:paper_reviewer_task, paper: paper, completed: true)
  end
  let(:register_decision_task) do
    FactoryGirl.create(:register_decision_task, paper: paper, completed: true)
  end

  it "marks all revision tasks as incomplete" do
    expect(paper_reviewer_task).to be_completed
    expect(register_decision_task).to be_completed
    described_class.call("tahi:paper:submitted", record: paper)
    expect(paper_reviewer_task.reload).to_not be_completed
    expect(register_decision_task.reload).to_not be_completed
  end
end
