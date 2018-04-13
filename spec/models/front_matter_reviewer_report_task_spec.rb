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

describe TahiStandardTasks::FrontMatterReviewerReportTask do
  it_behaves_like 'a reviewer report task', factory: :front_matter_reviewer_report_task

  context 'DEFAULT_TITLE' do
    subject { TahiStandardTasks::FrontMatterReviewerReportTask::DEFAULT_TITLE }
    it { is_expected.to eq('Front Matter Reviewer Report') }
  end

  context 'DEFAULT_ROLE_HINT' do
    subject { TahiStandardTasks::FrontMatterReviewerReportTask::DEFAULT_ROLE_HINT }
    it { is_expected.to eq('reviewer') }
  end

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults does not update title'
  end
end
