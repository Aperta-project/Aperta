require 'rails_helper'

class ScheduledEventTestTask < Task
  DEFAULT_TITLE = 'Mock Metadata Task'.freeze
  SCHEDULED_EVENTS_TEMPLATE = [
    { name: 'Pre-due Reminder', dispatch_offset: -2 },
    { name: 'First Late Reminder', dispatch_offset: 2 },
    { name: 'Second Late Reminder', dispatch_offset: 4 }
  ].freeze
  has_one :due_datetime, as: :due
end

shared_examples 'templated scheduled events' do |template|
  let(:owned_active_events) { ScheduledEvent.owned_by(reviewer_report.class.name, reviewer_report.id) }
  it 'should update times on active events correctly' do
    subject
    template.each do |entry|
      entry_event = owned_active_events.where(name: entry[:name]).first
      expect(entry_event.dispatch_at).to eq(reviewer_report.due_at + entry[:dispatch_offset].days)
    end
  end
end

describe ScheduledEventFactory do
  describe '#schedule_events' do
    let(:due_date) { FactoryGirl.create :due_datetime, :in_5_days }
    let(:reviewer_report) do
      FactoryGirl.create :reviewer_report, due_datetime: due_date
    end
    let(:template) { ScheduledEventTestTask::SCHEDULED_EVENTS_TEMPLATE }
    let(:owned_active_events) { ScheduledEvent.owned_by(reviewer_report.class.name, reviewer_report.id) }

    subject { described_class.new(reviewer_report, template).schedule_events }

    it 'should schedule events all' do
      number_of_events = template.count
      expect { subject }.to change { ScheduledEvent.count }.by(number_of_events)
    end

    it 'should schedule events as specified in the template' do
      subject
      expect(template.map { |x| x[:name] }).to include(ScheduledEvent.last.name)
    end

    context 'with existing scheduled events' do
      before do
        described_class.new(reviewer_report, template).schedule_events
      end

      context 'with one event triggered and review due date moved forward' do
        before do
          owned_active_events.first.trigger!
          reviewer_report.due_datetime.tap do |ddt|
            ddt.originally_due_at = ddt.due_at
            ddt.due_at = ddt.originally_due_at + 5.days
          end
        end

        it 'should reschedule already sent events' do
          expect { subject }.to change { ScheduledEvent.count }.by(1)
        end

        it 'should keep already fired events in list' do
          subject
          expect(owned_active_events.active.count).to be 3
          expect(owned_active_events.complete.count).to be 1
        end

        it_behaves_like 'templated scheduled events', ScheduledEventTestTask::SCHEDULED_EVENTS_TEMPLATE
      end

      context 'with one event triggered and review due date moved backward' do
        before do
          owned_active_events.first.trigger!
          reviewer_report.due_datetime.tap do |ddt|
            ddt.originally_due_at = ddt.due_at
            ddt.due_at = ddt.originally_due_at - 4.days
          end
        end

        it 'should deactivate events sent to the past' do
          subject
          expect(owned_active_events.complete.count).to be 1
          expect(owned_active_events.active.count).to be 2
        end

        it_behaves_like 'templated scheduled events', ScheduledEventTestTask::SCHEDULED_EVENTS_TEMPLATE
      end

      context 'when a scheduled event moves into the past without trigger' do
        before do
          reviewer_report.due_datetime.tap do |ddt|
            ddt.originally_due_at = ddt.due_at
            ddt.due_at = ddt.originally_due_at - 4.days
          end
        end
        it 'should deactivate an event' do
          subject
          expect(owned_active_events.inactive.count).to be 1
          expect(owned_active_events.active.count).to be 2
        end

        it_behaves_like 'templated scheduled events', ScheduledEventTestTask::SCHEDULED_EVENTS_TEMPLATE
      end
    end
  end
end
