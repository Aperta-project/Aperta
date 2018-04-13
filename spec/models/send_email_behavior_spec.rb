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

describe Behavior do
  let(:args) { { event_name: :fake_event } }
  let(:journal) { create(:journal) }
  let(:paper) { create(:paper, journal: journal) }
  let(:task) { create(:task, paper: paper, title: 'My Task') }
  let!(:template) { create(:letter_template, journal: journal, ident: 'foo-bar', scenario: 'Manuscript') }
  let(:event) { Event.new(name: :fake_event, paper: paper, task: task, user: paper.creator) }
  subject { create(:send_email_behavior, event_name: :fake_event, journal: journal, letter_template: 'foo-bar') }

  before(:each) do
    Event.register(:fake_event)
    subject.save!
  end

  after(:each) do
    Event.deregister(:fake_event)
  end

  it_behaves_like :behavior_subclass

  it 'should fail validation unless a letter_template is set' do
    subject.letter_template = nil
    expect(subject).not_to be_valid
    expect(subject.errors[:letter_template]).to eq(["can't be blank"])
  end

  it 'should call GenericMailer to send the email' do
    expect(GenericMailer).to receive_message_chain(:delay, :send_email).with(
      subject: template.subject,
      body: template.body,
      to: template.to,
      task: nil
    )
    event.trigger
  end
end
