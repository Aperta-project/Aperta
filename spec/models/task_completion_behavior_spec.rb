require 'rails_helper'
RSpec::Matchers.define_negated_matcher :not_change, :change

describe Behavior do
  let(:args) { { event_name: :fake_event } }
  let(:journal) { create(:journal) }
  let(:paper) { create(:paper, journal: journal) }
  let(:card) { FactoryGirl.create(:card, :versioned, journal: journal) }
  let(:cardversion) { card.latest_published_card_version }
  let(:task) { create(:task, paper: paper, title: 'My Task', card_version: cardversion, completed: completed) }
  let(:event) { Event.new(name: :fake_event, paper: paper, task: task, user: paper.creator) }
  subject { build(:task_completion_behavior, event_name: :fake_event, change_to: change_to, card_id: card.id, journal: journal) }

  before(:each) do
    Event.register(:fake_event)
  end

  after(:each) do
    Event.deregister(:fake_event)
  end

  context 'when the change_to is invalid' do
    let(:change_to) { 'invalid' }

    it 'the behavior should not be valid' do
      expect(subject).not_to be_valid
      expect(subject.errors[:change_to][0]).to match(/invalid should be one of the following/)
    end
  end

  context 'when the behavior is valid' do
    before(:each) { subject.save! }

    context "when change_to is incomplete" do
      let(:change_to) { 'incomplete' }
      context "and the task was completed" do
        let(:completed) { true }
        it "marks the task incomplete" do
          expect { event.trigger }.to change { task.reload.completed }.from(true).to(false)
        end
      end
      context "and the task was incomplete" do
        let(:completed) { false }
        it "does not change the task" do
          expect { event.trigger }.not_to(change { task.reload.completed })
        end
      end
    end

    context "when change_to is completed" do
      let(:change_to) { 'completed' }
      context "and the task was completed" do
        let(:completed) { true }
        it "does not change the task" do
          expect { event.trigger }.not_to(change { task.reload.completed })
        end
      end
      context "and the task was incomplete" do
        let(:completed) { false }
        it "marks the task completed" do
          expect { event.trigger }.to change { task.reload.completed }.from(false).to(true)
        end
      end
    end

    context "when card_id of the behavior does not match the card_id of the task" do
      let(:other_task) do
        create(
          :task,
          paper: paper,
          title: 'My Task',
          card_version: create(:card, :versioned, journal: journal).latest_published_card_version,
          completed: completed
        )
      end
      let(:change_to) { 'toggle' }

      context "and the task was completed" do
        let(:completed) { true }
        it "does not change the task" do
          expect { event.trigger }.not_to(change { other_task.reload.completed })
        end
      end
      context "and the task incomplete" do
        let(:completed) { false }
        it "does not change the task" do
          expect { event.trigger }.not_to(change { other_task.reload.completed })
        end
      end
    end

    context "when multiple tasks instances of the same card are on the same paper" do
      let!(:task2) { create(:task, paper: paper, title: 'My Task2', card_version: cardversion, completed: completed) }
      context "and change_to is incomplete" do
        let(:change_to) { 'incomplete' }
        context "and the task was completed" do
          let(:completed) { true }
          it "marks the task incomplete" do
            expect { event.trigger }.to \
              change { task.reload.completed }.from(true).to(false)
              .and change { task2.reload.completed }.from(true).to(false)
          end
        end
        context "and the task incomplete" do
          let(:completed) { false }
          it "marks the task incomplete" do
            expect { event.trigger }
              .to(not_change { task.reload.completed }
                 .and(not_change { task2.reload.completed }))
          end
        end
      end
      context "when change_to is completed" do
        let(:change_to) { 'completed' }
        context "and the task was completed" do
          let(:completed) { true }
          it "keeps the task completed" do
            expect { event.trigger }
              .to(not_change { task.reload.completed }
                 .and(not_change { task2.reload.completed }))
          end
        end
        context "and the task incomplete" do
          let(:completed) { false }
          it "marks the task completed" do
            expect { event.trigger }.to \
              change { task.reload.completed }.from(false).to(true)
              .and change { task2.reload.completed }.from(false).to(true)
          end
        end
      end
      context "when change_to is toggle" do
        let(:change_to) { 'toggle' }
        context "and the task was completed" do
          let(:completed) { true }
          it "marks the task incomplete" do
            expect { event.trigger }.to \
              change { task.reload.completed }.from(true).to(false)
              .and change { task2.reload.completed }.from(true).to(false)
          end
        end
        context "and the task incomplete" do
          let(:completed) { false }
          it "marks the task completed" do
            expect { event.trigger }.to \
              change { task.reload.completed }.from(false).to(true)
              .and change { task2.reload.completed }.from(false).to(true)
          end
        end
      end
    end
  end
end
