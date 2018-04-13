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

describe PlosBillingLogExportWorker do
  let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_academic_editor_user,
      :with_short_title,
      :with_creator,
      :accepted,
      journal: journal,
      short_title: 'my paper short',
      accepted_at: Time.now.utc
    )
  end

  let(:billing_task) do
    FactoryGirl.create(
      :billing_task,
      :with_card_content,
      completed: true,
      paper: paper
    )
  end

  let(:final_tech_check_task) do
    FactoryGirl.create(:final_tech_check_task, paper: paper)
  end

  let(:report) { FactoryGirl.create(:billing_log_report) }
  let(:uploader) { double(BillingFTPUploader) }

  before do
    CardLoader.load("PlosBilling::BillingTask")
    paper.phases.first.tasks.concat(
      [
        billing_task,
        final_tech_check_task
      ]
    )
  end

  it "creates BillingLogReport, FTPs resulting csv and adds Activity log" do
    expect(BillingLogReport).to receive(:create!).and_return(report)
    expect(report).to receive(:save_and_send_to_s3!)
    expect(report).to receive(:papers_to_process).and_return([paper])
    expect(BillingFTPUploader).to receive(:new).with(report).and_return(uploader)
    expect(uploader).to receive(:upload).and_return(true)
    expect(Activity).to receive(:create).with(hash_including(subject: paper))
    PlosBillingLogExportWorker.new.perform
  end
end
