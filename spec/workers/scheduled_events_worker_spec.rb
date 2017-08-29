require 'rails_helper'

shared_examples 'logged workflow activities' do
  it 'should log sending the reminder to the workflow activity' do
    allow_any_instance_of(TahiStandardTasks::ReviewerMailer).to receive(:remind_before_due)
    allow_any_instance_of(TahiStandardTasks::ReviewerMailer).to receive(:first_late_notice)
    allow_any_instance_of(TahiStandardTasks::ReviewerMailer).to receive(:second_late_notice)
    expect(Activity).to receive(:reminder_sent!)
    worker.perform
  end
end

describe ScheduledEventsWorker do
  let(:due_date) { FactoryGirl.create :due_datetime, :in_5_days }
  let(:reviewer_report) do
    FactoryGirl.create :reviewer_report, due_datetime: due_date
  end
  let(:template) { ReviewerReport::SCHEDULED_EVENTS_TEMPLATE }

  subject(:worker) { described_class.new }

  context 'after the pre due dispatch is past' do
    before do
      ScheduledEventFactory.new(reviewer_report, template).schedule_events
      Timecop.freeze(DateTime.now.utc + 4.days)
    end

    it 'should send the pre due email' do
      expect_any_instance_of(TahiStandardTasks::ReviewerMailer).to receive(:remind_before_due)
      worker.perform
    end

    it_behaves_like 'logged workflow activities'

    after do
      Timecop.return
    end
  end

  context 'after first event is dispatched' do
    before do
      ScheduledEventFactory.new(reviewer_report, template).schedule_events
      reviewer_report.scheduled_events.first.tap do |event|
        event.state = 'completed'
        event.save
      end
      Timecop.freeze(DateTime.now.utc + 8.days)
    end

    it 'should not trigger already completed events' do
      expect_any_instance_of(TahiStandardTasks::ReviewerMailer).not_to receive(:remind_before_due)
      expect_any_instance_of(TahiStandardTasks::ReviewerMailer).to receive(:first_late_notice)
      worker.perform
    end

    it_behaves_like 'logged workflow activities'

    after do
      Timecop.return
    end
  end
end
