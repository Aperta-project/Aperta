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

describe TahiStandardTasks::ReviseTask do
  describe "#setup_new_revision" do
    let!(:paper) do
      FactoryGirl.create(
        :paper_with_phases,
        editable: false,
        phases_count: 3
      )
    end

    let(:phase) { paper.phases[1] }
    subject(:subject) { TahiStandardTasks::ReviseTask }

    context "with an existing revise task" do
      let!(:task) do
        FactoryGirl.create(
          :revise_task,
          :with_loaded_card,
          completed: true,
          paper: paper
        )
      end

      it "uncompletes the task" do
        subject.setup_new_revision paper, phase
        expect(task.reload.completed).to be(false)
      end

      it "updates the task's phase" do
        subject.setup_new_revision paper, phase
        expect(task.reload.phase_id).to be(phase.id)
      end
    end

    context "with no existing revise task" do
      before do
        CardLoader.load("TahiStandardTasks::ReviseTask")
      end

      it "creates a new revise task" do
        expect(TaskFactory)
          .to receive(:create).with(
            subject,
            paper: paper,
            phase: phase
          )

        subject.setup_new_revision paper, phase
      end
    end
  end

  describe "Attachments owned by ReviseTask" do
    let(:attachment) { FactoryGirl.create(:adhoc_attachment, :with_revise_task) }

    it "maintains existence in snapshot after atachment destroyed" do
      allow(attachment).to receive(:non_expiring_proxy_url).and_return('')
      allow(attachment.paper).to receive(:major_version).and_return(0)
      allow(attachment.paper).to receive(:minor_version).and_return(0)

      SnapshotService.new(attachment.paper).snapshot!(attachment)
      attachment.destroy!
      attachment = nil
      file_in_snapshot = Snapshot.last.contents['children'].any? do |child|
        child['name'] == 'file'
      end
      expect(file_in_snapshot).to be(true)
    end
  end

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end
end
