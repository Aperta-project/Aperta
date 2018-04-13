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

require "rails_helper"

describe ParticipationFactory do
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_task_participant_role
    )
  end

  describe '.create' do
    let(:assignee) { FactoryGirl.create(:user) }
    let(:assigner) { FactoryGirl.create(:user) }
    let(:full_params) { { task: task, assignee: assignee, assigner: assigner } }
    let(:same_params) { { task: task, assignee: assignee, assigner: assignee } }

    it 'does not sent notification when the notify flag is set to true' do
      expect(UserMailer).to_not receive(:delay)
      ParticipationFactory.create(task: task, assignee: assignee, notify: false)
    end

    it 'queues up an email notification to the assignee' do
      expect(UserMailer).to receive_message_chain('delay.add_participant')
      ParticipationFactory.create(full_params)
    end

    it 'does not create a participation if already participant' do
      task.add_participant assignee
      expect do
        ParticipationFactory.create(full_params)
      end.to_not change { task.participations.count }
    end

    it 'creates a new participation assignment' do
      expect do
        ParticipationFactory.create(full_params)
      end.to change { task.participations.count }.by(1)
    end

    it 'does not email the assignee if is the same as the assigner' do
      expect(UserMailer).to_not receive(:delay)
      ParticipationFactory.create(same_params)
    end
  end
end
