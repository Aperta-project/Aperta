require 'rails_helper'

describe ScheduledEventFactory do
  describe '#schedule_events' do
    let(:due_date) { FactoryGirl.create :due_datetime, :in_5_days }
    let(:reviewer_report) do
      FactoryGirl.create :reviewer_report, due_datetime: due_date
    end
    let(:template) { ReviewerReport::SCHEDULED_EVENTS_TEMPLATE }

    subject { described_class.new(reviewer_report, ReviewerReport::SCHEDULED_EVENTS_TEMPLATE).schedule_events }

    it 'should schedule events all' do
      number_of_events = template.count
      expect { subject }.to change { ScheduledEvent.count }.by(number_of_events)
    end

    it 'should schedule events as specified in the template' do
      subject
      expect(template.map { |x| x[:name] }).to include(ScheduledEvent.last.name)
    end
  end
end
