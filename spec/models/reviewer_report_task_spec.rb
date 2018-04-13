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

describe TahiStandardTasks::ReviewerReportTask do
  it_behaves_like 'a reviewer report task', factory: :reviewer_report_task

  context 'DEFAULT_TITLE' do
    subject { TahiStandardTasks::ReviewerReportTask::DEFAULT_TITLE }
    it { is_expected.to eq('Reviewer Report') }
  end

  context 'DEFAULT_ROLE_HINT' do
    subject { TahiStandardTasks::ReviewerReportTask::DEFAULT_ROLE_HINT }
    it { is_expected.to eq('reviewer') }
  end

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults does not update title'
  end

  describe "#display_status" do
    let(:task) { FactoryGirl.create(:reviewer_report_task) }
    let(:report1) { FactoryGirl.create(:reviewer_report, state: "submitted") }
    let(:report2) { FactoryGirl.create(:reviewer_report, state: "invitation_not_accepted") }
    let(:report3) { FactoryGirl.create(:reviewer_report, state: "review_pending") }
    before do
      task.reviewer_reports << report1
    end

    context "with the lsat reviewer report state set to submitted" do
      it "returns active_check" do
        expect(task.display_status).to eq(:active_check)
      end
    end

    context "with the last reviewer report state set to invitation_not_accepted" do
      before { task.reviewer_reports << report2 }
      it "return minus" do
        expect(task.display_status).to eq(:minus)
      end
    end

    context "with the last reviewer report state set to pending" do
      before { task.reviewer_reports << report3 }
      it "return minus" do
        expect(task.display_status).to eq(:check)
      end
    end
  end
end
