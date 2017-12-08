require 'rails_helper'

describe Behavior do
  let(:args) { { event_name: :fake_event } }
  let(:journal) { create(:journal) }
  let(:paper) { create(:paper, journal: journal) }
  let(:card) { FactoryGirl.create(:card, :versioned) }
  let(:cardversion) { card.latest_published_card_version }
  let(:task) { create(:task, paper: paper, title: 'My Task', card_version: cardversion, completed: completed) }
  let(:event) { Event.new(name: :fake_event, paper: paper, task: task, user: paper.creator) }
  subject { build(:task_completion_behavior, change_to: change_to, card_id: card_id) }

  before(:each) do
    Event.register(:fake_event)
    allow(Behavior).to receive(:where).with(event_name: :fake_event).and_return([subject])
  end

  after(:each) do
    Event.deregister(:fake_name)
  end

  context "when change_to is incomplete" do
    let(:change_to) { 'incomplete' }
    let(:card_id) { card.id }
    context "and the task was completed" do
      let(:completed) { true }
      it "marks the task incomplete" do
        expect { event.trigger }.to change { task.reload.completed }.from(true).to(false)
      end
    end
    context "and the task incomplete" do
      let(:completed) { false }
      it "marks the task incomplete" do
        event.trigger
        expect(task.reload.completed).to be(false)
      end
    end
  end

  context "when change_to is completed" do
    let(:change_to) { 'completed' }
    let(:card_id) { card.id }
    context "and the task was completed" do
      let(:completed) { true }
      it "marks the task completed" do
        expect(task.reload.completed).to be(true)
      end
    end
    context "and the task incomplete" do
      let(:completed) { false }
      it "marks the task completed" do
        expect { event.trigger }.to change { task.reload.completed }.from(false).to(true)
      end
    end
  end

  context "when change_to is toggle" do
    let(:change_to) { 'toggle' }
    let(:card_id) { card.id }
    context "and the task was completed" do
      let(:completed) { true }
      it "marks the task incomplete" do
        expect { event.trigger }.to change { task.reload.completed }.from(true).to(false)
      end
    end
    context "and the task incomplete" do
      let(:completed) { false }
      it "marks the task completed" do
        expect { event.trigger }.to change { task.reload.completed }.from(false).to(true)
      end
    end
  end

  context "when change_to is not a valid value" do
    let(:change_to) { 'invalid' }
    let(:card_id) { card.id }
    context "and the task was completed" do
      let(:completed) { true }
      it "marks the task unchanged" do
        event.trigger
        expect(task.reload.completed).to be(true)
      end
    end
    context "and the task incomplete" do
      let(:completed) { false }
      it "marks the task unchanged" do
        event.trigger
        expect(task.reload.completed).to be(false)
      end
    end
  end

  context "when card_id of the behavior does not match the card_id of the task" do
    let(:different_card) { FactoryGirl.create(:card, :versioned) }
    let(:change_to) { 'toggle' }
    let(:card_id) { different_card.id }
    context "and the task was completed" do
      let(:completed) { true }
      it "marks the task unchanged" do
        event.trigger
        expect(task.reload.completed).to be(true)
      end
    end
    context "and the task incomplete" do
      let(:completed) { false }
      it "marks the task unchanged" do
        event.trigger
        expect(task.reload.completed).to be(false)
      end
    end
  end

  context "when multiple tasks instances of the same card are on the same paper" do
    let!(:task2) { create(:task, paper: paper, title: 'My Task2', card_version: cardversion, completed: completed) }
    context "and change_to is incomplete" do
      let(:change_to) { 'incomplete' }
      let(:card_id) { card.id }
      context "and the task was completed" do
        let(:completed) { true }
        it "marks the task incomplete" do
          event.trigger
          expect(task.reload.completed).to be(false)
          expect(task2.reload.completed).to be(false)
        end
      end
      context "and the task incomplete" do
        let(:completed) { false }
        it "marks the task incomplete" do
          event.trigger
          expect(task.reload.completed).to be(false)
          expect(task2.reload.completed).to be(false)
        end
      end
    end
    context "when change_to is completed" do
      let(:change_to) { 'completed' }
      let(:card_id) { card.id }
      context "and the task was completed" do
        let(:completed) { true }
        it "marks the task completed" do
          event.trigger
          expect(task.reload.completed).to be(true)
          expect(task2.reload.completed).to be(true)
        end
      end
      context "and the task incomplete" do
        let(:completed) { false }
        it "marks the task completed" do
          event.trigger
          expect(task.reload.completed).to be(true)
          expect(task2.reload.completed).to be(true)
        end
      end
    end
    context "when change_to is toggle" do
      let(:change_to) { 'toggle' }
      let(:card_id) { card.id }
      context "and the task was completed" do
        let(:completed) { true }
        it "marks the task incomplete" do
          event.trigger
          expect(task.reload.completed).to be(false)
          expect(task2.reload.completed).to be(false)
        end
      end
      context "and the task incomplete" do
        let(:completed) { false }
        it "marks the task completed" do
          event.trigger
          expect(task.reload.completed).to be(true)
          expect(task2.reload.completed).to be(true)
        end
      end
    end
  end
end
