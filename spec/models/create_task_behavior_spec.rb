require 'rails_helper'

describe Behavior do
  let(:args) { { event_name: :fake_event } }
  let(:journal) { create(:journal) }
  let(:paper) { create(:paper, :with_phases, journal: journal) }
  let(:card) { FactoryGirl.create(:card, journal: journal) }
  let(:event) { Event.new(name: :fake_event, paper: paper, task: nil, user: nil) }

  before(:each) do
    Event.register(:fake_event, :paper_submitted)
    allow(Behavior).to receive(:where).with(event_name: :fake_event).and_return([subject])
  end

  after(:each) do
    Event.deregister(:fake_name)
  end

  it_behaves_like :behavior_subclass

  describe 'basic case' do
    subject { build(:create_task_behavior, card_id: card.id, duplicates_allowed: false) }

    before(:each) do
      allow(subject).to receive(:duplicates_allowed).and_return(true)
      allow(subject).to receive(:card_id).and_return(card.id)
    end

    # it 'should fail validation unless a card_id is set' do
    #   expect(subject).not_to be_valid
    # end

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
    subject { build(:create_task_behavior, card_id: card.id, duplicates_allowed: false) }
    let!(:task) { create(:task, paper: paper, title: card.name) }

    before(:each) do
      allow(subject).to receive(:duplicates_allowed).and_return(false)
      allow(subject).to receive(:card_id).and_return(card.id)
    end

    it 'should create the correct tasks from the event attributes' do
      expect(TaskFactory).not_to receive(:create)
      .with(CustomCardTask, mock_task_opts(card, event))
      event.trigger
    end
  end

  describe 'with allowed duplicate' do
    subject { build(:create_task_behavior, card_id: card.id, duplicates_allowed: true) }
    let!(:task) { create(:task, paper: paper, title: card.name) }

    before(:each) do
      allow(subject).to receive(:duplicates_allowed).and_return(true)
      allow(subject).to receive(:card_id).and_return(card.id)
    end

    it 'should create the correct tasks from the event attributes' do
      expect(TaskFactory).to receive(:create)
      .with(CustomCardTask, mock_task_opts(card, event))
      event.trigger
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
