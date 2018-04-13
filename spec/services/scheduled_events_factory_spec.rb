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
  it 'should update times on active events correctly' do
    subject
    template.each do |entry|
      entry_event = own_events.where(name: entry[:name]).first!
      dispatch_with_offset = (reviewer_report.due_at + entry[:dispatch_offset].days).beginning_of_hour
      expect(entry_event.dispatch_at).to eq(dispatch_with_offset)
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
    let(:own_events) { reviewer_report.due_datetime.scheduled_events }

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
        allow_any_instance_of(ScheduledEvent).to receive(:send_email) { true }
        described_class.new(reviewer_report, template).schedule_events
      end

      context 'with one complete event and review due date moved forward' do
        before do
          own_events.first.tap do |e|
            e.state = 'completed'
            e.save
          end
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
          expect(own_events.active.count).to be 3
          expect(own_events.completed.count).to be 1
        end

        it_behaves_like 'templated scheduled events', ScheduledEventTestTask::SCHEDULED_EVENTS_TEMPLATE
      end

      context 'with one inactive event and review due date moved forward' do
        before do
          own_events.first.tap do |e|
            e.dispatch_at = DateTime.now.in_time_zone - 1.hour
            e.state = 'inactive'
            e.save!
          end
          reviewer_report.due_datetime.tap do |ddt|
            ddt.originally_due_at = ddt.due_at
            ddt.due_at = ddt.originally_due_at + 5.days
          end
        end

        it 'should reschedule inactive events' do
          expect(own_events.active.count).to be 2
          expect { subject }.to change { ScheduledEvent.count }.by(0)
          expect(own_events.active.count).to be 3
        end

        it_behaves_like 'templated scheduled events', ScheduledEventTestTask::SCHEDULED_EVENTS_TEMPLATE
      end

      context 'with one completed event and review due date moved backward' do
        before do
          own_events.first.tap do |e|
            e.state = 'completed'
            e.save
          end
          reviewer_report.due_datetime.tap do |ddt|
            ddt.originally_due_at = ddt.due_at
            ddt.due_at = ddt.originally_due_at - 4.days
          end
        end

        it 'should disable events sent to the past' do
          subject
          expect(own_events.completed.count).to be 1
          expect(own_events.active.count).to be 2
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
        it 'should disable an event' do
          subject
          expect(own_events.inactive.count).to be 1
          expect(own_events.active.count).to be 2
        end

        it_behaves_like 'templated scheduled events', ScheduledEventTestTask::SCHEDULED_EVENTS_TEMPLATE
      end

      context 'when all scheduled events are in the passive state' do
        it 'should not change the event count' do
          reviewer_report.due_datetime.scheduled_events.each(&:switch_off!)
          DueDatetime.set_for(reviewer_report, length_of_time: 10.days)
          expect { subject }.to change { ScheduledEvent.count }.by(0)
        end
      end
    end
  end
end
