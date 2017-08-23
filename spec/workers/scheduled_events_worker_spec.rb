require 'rails_helper'

describe ScheduledEventsWorker do
  let(:due_date) { FactoryGirl.create :due_datetime, :in_5_days }
  let(:reviewer_report) do
    FactoryGirl.create :reviewer_report, due_datetime: due_date
  end
  let(:template) { ReviewerReport::SCHEDULED_EVENTS_TEMPLATE }

  context 'after the pre due dispatch is past' do
    before do
      ScheduledEventFactory.new(reviewer_report, template).schedule_events
      Timecop.freeze(DateTime.now.utc + 4.days)
    end

    it 'should send the pre due email' do
      worker = ScheduledEventsWorker.new
      expect_any_instance_of(TahiStandardTasks::ReviewerMailer).to receive(:remind_before_due)
      worker.perform
    end

    after do
      Timecop.return
    end
  end
end
