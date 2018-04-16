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
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, :with_phases, journal: journal) }
  let(:card) { FactoryGirl.create(:card, :versioned, journal: journal) }
  let(:card_id) { card.id }
  let(:event) { Event.new(name: :fake_event, paper: paper, task: nil, user: nil) }
  let(:duplicates_allowed) { true }
  subject { FactoryGirl.build(:create_task_behavior, card_id: card_id, event_name: :fake_event, duplicates_allowed: duplicates_allowed, journal: journal) }

  def mock_task_opts(card, event)
    { "completed" => false,
      "title" => card.name,
      "phase_id" => event.paper.phases.first.id,
      "body" => [],
      'paper' => event.paper,
      'card_version' => card.latest_published_card_version }
  end

  before(:each) do
    Event.register(:fake_event, :paper_submitted)
  end

  after(:each) do
    Event.deregister(:fake_event, :paper_submitted)
  end

  context 'when the behavior is valid' do
    before(:each) { subject.save! }

    it_behaves_like :behavior_subclass

    describe 'basic case' do
      it 'should create the correct tasks from the event attributes' do
        expect(TaskFactory).to receive(:create).with(CustomCardTask, mock_task_opts(card, event))
        event.trigger
      end
    end

    describe 'with disallowed duplicate' do
      let(:duplicates_allowed) { false }
      let!(:task) { FactoryGirl.create(:task, paper: paper, title: card.name, card_version: card.card_versions.first) }

      it 'should not create a task' do
        expect(TaskFactory).not_to receive(:create).with(CustomCardTask, mock_task_opts(card, event))
        event.trigger
      end
    end

    describe 'with duplicates allowed' do
      let(:duplicates_allowed) { true }
      let!(:task) { FactoryGirl.create(:task, paper: paper, title: card.name) }

      it 'should create the correct tasks from the event attributes' do
        expect(TaskFactory).to receive(:create)
                                 .with(CustomCardTask, mock_task_opts(card, event))
        event.trigger
      end
    end
  end

  describe 'with a card from another journal' do
    let(:journal2) { FactoryGirl.create(:journal) }
    let(:card2) { FactoryGirl.create(:card, journal: journal2) }
    subject do
      FactoryGirl.build(
        :create_task_behavior,
        card_id: card2.id,
        duplicates_allowed: true,
        journal: journal
      )
    end

    let!(:task) { FactoryGirl.create(:task, paper: paper, title: card.name) }

    it 'should fail validation' do
      expect(subject).not_to be_valid
    end
  end

  describe 'without a duplicates allowed property' do
    subject { FactoryGirl.build(:create_task_behavior, card_id: card.id, duplicates_allowed: nil) }
    let!(:task) { FactoryGirl.create(:task, paper: paper, title: card.name) }

    it 'should fail validation unless a card_id is set' do
      expect(subject).not_to be_valid
    end
  end

  describe 'without a card id ' do
    let(:card_id) { nil }
    let!(:task) { FactoryGirl.create(:task, paper: paper, title: card.name) }

    it 'should fail validation unless a card_id is set' do
      expect(subject).not_to be_valid
    end
  end
end
