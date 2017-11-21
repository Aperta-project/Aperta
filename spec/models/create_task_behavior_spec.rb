require 'rails_helper'

describe Behavior do
  let(:args) { { event_name: :fake_event } }
  let(:journal) { create(:journal) }
  let(:paper) { create(:paper, journal: journal) }


  #describe 'for CustomCardTask'
    #describe with  disallowedduplicates
    #describe without disallowedduplicates

  #describe 'for TahiStandardTask'
    #describe with  disallowedduplicates
    #describe without disallowedduplicates
  let(:card) { FactoryGirl.create(:card, journal: journal) }
  let(:event) { Event.new(name: :fake_event, paper: paper, task: nil, user: nil) }
  let!(:task) { create(:task, paper: paper, title: card.name) }
  subject { build(:create_task_behavior, card_id: card.id, duplicates_allowed: false) }

  before(:each) do
    Event.register(:fake_event, :paper_submitted)
    allow(Behavior).to receive(:where).with(event_name: :fake_event).and_return([subject])
    allow(subject).to receive(:card_id).and_return(card.id)
    allow(subject).to receive(:duplicates_allowed).and_return(true)
  end

  after(:each) do
    Event.deregister(:fake_name)
  end

  it_behaves_like :behavior_subclass

  # it 'should fail validation unless a card_id is set' do
  #   expect(subject).not_to be_valid
  # end

  it 'should call the behavior' do
    expect(subject).to receive(:call).with(event)
    event.trigger
  end

  it 'should create the correct tasks from the event attributes' do
    expect(TaskFactory).to receive(:create)
    .with(Task,
      { "completed" => false,
        "title" => card.name,
        "phase_id" => event.paper.phases.first.id,
        "body" => [],
        'paper' => event.paper,
        'card_version' => card.latest_published_card_version }
    )
    event.trigger
  end

  describe 'with '
end
