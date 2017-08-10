require 'rails_helper'

describe ScheduledEventFactory do
  describe '#schedule_events' do
    let(:due_date) { FactoryGirl.create :due_datetime, :in_5_days }
    let(:reviewer_report) do
      FactoryGirl.create :reviewer_report, due_datetime: due_date
    end
    let(:template) { ReviewerReport::SCHEDULED_EVENTS_TEMPLATE }
    let(:max_offset) { template.max_by { |t| t[:dispatch_offset] }[:dispatch_offset] }

    subject { described_class.new(reviewer_report, template).schedule_events }

    it 'should schedule events all' do
      number_of_events = template.count
      expect { subject }.to change { ScheduledEvent.count }.by(number_of_events)
    end

    it 'should schedule events as specified in the template' do
      subject
      expect(template.map { |x| x[:name] }).to include(ScheduledEvent.last.name)
    end

    context 'when scheduled events exists for object' do
      before do
        subject
        reviewer_report.due_datetime.update_attribute(:due_at, reviewer_report.due_at + (max_offset + 1).days)
      end

      it "should attempt to reschedule events" do
        expect { subject }.to change { ScheduledEvent.count }.by(template.count)
      end
    end
  end
end
