require 'rails_helper'

describe ScheduledEventFactory do
  describe 'schedule_events' do
    let(:due_datetime) { FactoryGirl.create :due_datetime }
    let(:reviewer_report) do
      FactoryGirl.create :reviewer_report
    end

    subject { described_class.schedule_events reviewer_report }

    context 'with templates in the system' do
      let!(:first_event) { FactoryGirl.create :scheduled_event_template }
      let!(:second_event) { FactoryGirl.create :scheduled_event_template }

      it 'should schedule events all' do
        expect { subject }.to change { ScheduledEvent.count }.by(2)
      end

      it 'should schedule events as specified in the template' do
        subject
        expect([first_event.event_name, second_event.event_name]).to include(ScheduledEvent.last.name)
      end
    end

    context 'already existing events'
    context 'past effective dispatch date'
  end
end
