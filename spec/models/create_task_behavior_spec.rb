require 'rails_helper'

describe Behavior do
  let(:args) { { event_name: :fake_event } }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, :with_phases, journal: journal) }
  let(:card) { FactoryGirl.create(:card, :versioned, journal: journal) }
  let(:event) { Event.new(name: :fake_event, paper: paper, task: nil, user: nil) }

  before(:each) do
    Event.register(:fake_event, :paper_submitted)
    allow(Behavior).to receive(:where).with(event_name: :fake_event).and_return([subject])
  end

  after(:each) do
    Event.deregister(:fake_event, :paper_submitted)
  end

  it_behaves_like :behavior_subclass

  describe 'basic case' do
    subject do
      FactoryGirl.build(
        :create_task_behavior,
        card_id: card.id,
        duplicates_allowed: true,
        journal: journal
      )
    end

    it 'should pass validation unless a card_id is set' do
      expect(subject).to be_valid
    end

    it 'should call the behavior' do
      expect(subject).to receive(:call).with(event)
      event.trigger
    end

    it 'should create the correct tasks from the event attributes' do
      expect(TaskFactory).to receive(:create)
      .with(CustomCardTask, mock_task_opts(card, event))
      event.trigger
    end
  end

  describe 'with disallowed duplicate' do
    subject do
      FactoryGirl.build(
        :create_task_behavior,
        card_id: card.id,
        duplicates_allowed: false
      )
    end

    let!(:task) { FactoryGirl.create(:task, paper: paper, title: card.name, card_version: card.card_versions.first) }

    it 'should not create a task' do
      expect(TaskFactory).not_to receive(:create)
      .with(CustomCardTask, mock_task_opts(card, event))
      event.trigger
    end
  end

  describe 'with duplicates allowed' do
    subject { FactoryGirl.build(:create_task_behavior, card_id: card.id, duplicates_allowed: true) }
    let!(:task) { FactoryGirl.create(:task, paper: paper, title: card.name) }

    it 'should create the correct tasks from the event attributes' do
      expect(TaskFactory).to receive(:create)
      .with(CustomCardTask, mock_task_opts(card, event))
      event.trigger
    end
  end

  describe 'without a card id ' do
    subject { FactoryGirl.build(:create_task_behavior, card_id: nil, duplicates_allowed: true) }
    let!(:task) { FactoryGirl.create(:task, paper: paper, title: card.name) }

    it 'should fail validation unless a card_id is set' do
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

  describe 'without a card from another journal' do
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

    it 'should fail validation unless a card_id is set' do
      expect(subject).not_to be_valid
    end
  end
end

def mock_task_opts(card, event)
  { "completed" => false,
    "title" => card.name,
    "phase_id" => event.paper.phases.first.id,
    "body" => [],
    'paper' => event.paper,
    'card_version' => card.latest_published_card_version }
end
