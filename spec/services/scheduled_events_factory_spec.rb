require 'rails_helper'

describe ScheduledEventFactory do
  describe 'schedule_events' do
    let(:due_datetime) { FactoryGirl.create :due_datetime }
    let(:reviewer_report) { FactoryGirl.create :reviewer_report }

    subject { described_class.schedule_events reviewer_report }

    context 'with templates in the system' do
      let(:first_event) { FactoryGirl.create :scheduled_event_template }
      let(:second_event) { FactoryGirl.create :scheduled_event_template }

      before do
        ScheduledEventFactory.schedule_events reviewer_report
      end

      it 'should schedule events all' do
        expect(ScheduledEvent.count).to eq(2)
      end

      it 'should schedule events as specified in the template' do
        expect([first_event.event_name, second_event.event_name]).to include(ScheduledEvent.last.name)
      end
    end
  end
end
