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

describe TahiStandardTasks::PaperReviewerTask do
  subject(:task) do
    FactoryGirl.create(:paper_reviewer_task, paper: paper)
  end

  let(:paper) do
    FactoryGirl.create(:paper, :with_academic_editor_user, journal: journal)
  end
  let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe "#invitation_invited" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    it_behaves_like 'a task that sends out invitations',
      invitee_role: Role::REVIEWER_ROLE

    it "notifies the invited reviewer" do
      expect { task.invitation_invited invitation }.to change {
        Sidekiq::Extensions::DelayedMailer.jobs.length
      }.by(1)
    end
  end

  describe "#invitation_accepted" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }
    before do
      allow(ReviewerReportTaskCreator).to \
        receive(:new)
        .and_return double(process: nil)
    end

    context "with an academic editor" do
      let(:paper) do
        FactoryGirl.create(:paper, :with_academic_editor_user, journal: journal)
      end
      let(:journal) { FactoryGirl.create(:journal, :with_academic_editor_role) }

      before do
        academic_editor = paper.assignments.find_by \
          role: journal.academic_editor_role
        expect(academic_editor).to be
      end

      it "queues the email" do
        task.invitation_accepted invitation
        expect(Sidekiq::Extensions::DelayedMailer).to have_queued_mailer_job(
          TahiStandardTasks::ReviewerMailer,
          :reviewer_accepted,
          [{ invitation_id: invitation.id }]
        )
      end
    end

    context "without a paper editor" do
      before do
        paper.assignments.where(role: paper.journal.academic_editor_role)
             .destroy_all
      end

      it "queues the email" do
        task.invitation_accepted invitation
        expect(Sidekiq::Extensions::DelayedMailer).to have_queued_mailer_job(
          TahiStandardTasks::ReviewerMailer,
          :reviewer_accepted,
          [{ invitation_id: invitation.id }]
        )
      end
    end
  end

  describe "#invitation_declined" do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }

    context "with a paper editor" do
      it "queues the email" do
        task.invitation_declined invitation
        expect(Sidekiq::Extensions::DelayedMailer).to have_queued_mailer_job(
          TahiStandardTasks::ReviewerMailer,
          :reviewer_declined,
          [{ invitation_id: invitation.id }]
        )
      end
    end

    context "without a paper editor" do
      before do
        paper.assignments.where(role: paper.journal.academic_editor_role)
             .destroy_all
      end

      it "queues the email" do
        task.invitation_declined invitation
        expect(Sidekiq::Extensions::DelayedMailer).to have_queued_mailer_job(
          TahiStandardTasks::ReviewerMailer,
          :reviewer_declined,
          [{ invitation_id: invitation.id }]
        )
      end
    end
  end

  describe '#accept_allowed?' do
    let(:invitation) { FactoryGirl.create(:invitation, :invited, task: task) }
    it 'returns false when no invitee is present' do
      expect(invitation).to receive(:invitee).and_return(nil)
      expect(task.accept_allowed?(invitation)).to be false
    end

    it 'returns false when no invitee is present' do
      expect(invitation).to receive(:invitee).and_return(double('User'))
      expect(task.accept_allowed?(invitation)).to be true
    end
  end
end
