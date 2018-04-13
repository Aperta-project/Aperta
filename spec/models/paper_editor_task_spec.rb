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

describe TahiStandardTasks::PaperEditorTask do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper_with_phases, journal: journal) }
  let!(:author) { FactoryGirl.create(:author, paper: paper) }
  let(:task) do
    FactoryGirl.create(
      :paper_editor_task,
      paper: paper,
      phase: paper.phases.first
    )
  end

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe "#invitation_invited" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it_behaves_like 'a task that sends out invitations',
      invitee_role: Role::ACADEMIC_EDITOR_ROLE

    it "notifies the invited editor" do
      expect do
        task.invitation_invited(invitation)
      end.to change(Sidekiq::Extensions::DelayedMailer.jobs, :length).by(1)
    end
  end

  describe "#invitation_accepted" do
    before do
      Role.ensure_exists(Role::ACADEMIC_EDITOR_ROLE, journal: journal)
    end

    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it 'adds the invitee as an Academic Editor on the paper' do
      invitation.accept!
      expect(paper.academic_editors).to include(invitation.invitee)
    end

    it 'does not queue up any emails' do
      expect do
        invitation.accept!
      end.to_not change { Sidekiq::Extensions::DelayedMailer.jobs.count }
    end
  end

  describe "PaperEditorTask.task_added_to_paper" do
    it "creates a queue for the task" do
      task.task_added_to_paper(task)
      expect(task.invitation_queue).to be_present
    end
  end
end
