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

describe TahiStandardTasks::InitialDecisionTask do
  let(:paper) { FactoryGirl.create :paper, :submitted_lite, :with_tasks }
  let(:task) { FactoryGirl.create :initial_decision_task, paper: paper }
  let(:decision) { paper.draft_decision }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe '#initial_decision' do
    it 'gets initial decision' do
      expect(task.initial_decision).to eq(task.paper.decisions.last)
    end
  end

  describe '.task_added_to_paper' do
    it 'sets gradual_engagement attribute to true' do
      expect { task.task_added_to_paper(paper) }
        .to change { paper.reload.gradual_engagement }.from(false).to(true)
    end
  end

  describe '#before_register' do
    it "sets the decision to be initial" do
      expect { task.before_register decision }
        .to change { decision.initial }.from(false).to(true)
    end
  end

  describe '#after_register' do
    it "marks the task complete" do
      expect(task).to receive(:complete!)
      task.after_register decision
    end
  end

  describe '#register_decision with a InitialDecisionTask`' do
    # This is somewhat duplicative of the test for `#before_register`, but this
    # ensures that the change to `initial` is saved.
    it 'sets the decision to be initial' do
      expect { decision.register! task }
        .to change { decision.reload.initial }.from(false).to(true)
    end
  end

  describe "#send_email" do
    let!(:decision_one) do
      FactoryGirl.create(
        :decision,
        verdict: 'invite_full_submission',
        paper: paper,
        major_version: 0,
        minor_version: 0)
    end

    it "will email using last completed decision" do
      expect(TahiStandardTasks::InitialDecisionMailer)
        .to receive_message_chain(:delay, :notify)
        .with(decision_id: decision_one.id)
      task.send_email
    end
  end
end
