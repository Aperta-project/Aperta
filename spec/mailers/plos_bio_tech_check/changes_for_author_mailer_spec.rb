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

describe PlosBioTechCheck::ChangesForAuthorMailer do
  let(:task) do
    FactoryGirl.build_stubbed(:changes_for_author_task, paper: paper)
  end
  let(:paper) { FactoryGirl.build_stubbed(:paper, journal: journal) }
  let(:journal) { FactoryGirl.build_stubbed(:journal) }
  let(:user) { FactoryGirl.build_stubbed(:user) }

  describe '#notify_changes_for_author' do
    subject(:email) do
      described_class.notify_changes_for_author(
        author_id: user.id,
        task_id: task.id
      )
    end

    before do
      allow(Task).to receive(:find).with(task.id).and_return task
      allow(User).to receive(:find).with(user.id).and_return user
      task.letter_text = "Changes for good"
    end

    it "sends an email to author" do
      expect(email.to.length).to eq 1
      expect(email.to.first).to eq user.email
      expect(email.subject).to eq "Changes needed on your Manuscript in #{journal.name}"
      expect(email.body.raw_source).to match user.full_name
      expect(email.body.raw_source).to match paper.journal.name
      expect(email.body.raw_source).to include task.letter_text
      expect(email.body.raw_source).to match 'http://'
    end

    context "with line breaks in body .json content" do
      before do
        task.letter_text = "with\nline\nbreaks"
      end

      it "replace line breaks with html breaks" do
        expect(email.body).to_not include "with\nline\nbreaks"
        expect(email.body).to include "<p>with\n<br />line\n<br />breaks</p>"
      end
    end
  end
end
