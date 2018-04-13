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

describe PlosBioTechCheck::ChangesForAuthorTask do
  let(:paper) do
    FactoryGirl.create :paper, :submitted, journal: journal
  end
  let(:journal) { FactoryGirl.create(:journal, :with_creator_role) }
  let(:task) { FactoryGirl.build :changes_for_author_task, paper: paper }
  let(:user) { FactoryGirl.create :user }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end

  describe "#notify_changes_for_author" do
    it "queues an email to send" do
      expect { task.notify_changes_for_author }
        .to change { Sidekiq::Extensions::DelayedMailer.jobs.length }.by 1
    end
  end

  describe '#completed' do
    context 'when the author marks the task complete' do
      it 'stays completed' do
        task.update_attribute 'completed', true
        expect(task.completed).to be true
      end
    end
  end
end
