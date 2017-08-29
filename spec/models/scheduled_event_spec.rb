require 'rails_helper'

describe ScheduledEvent do
  before do
    subject { FactoryGirl.create :scheduled_event }
  end

  describe '.state' do
    it 'defaults to active' do
      expect(subject.active?).to be true
    end

    it 'can move from active to inactive' do
      subject.deactivate
      expect(subject.inactive?).to be true
    end

    it 'can move from inactive to active' do
      subject.deactivate
      subject.reactivate
      expect(subject.active?).to be true
    end

    it 'can move from active to processing' do
      subject.trigger
      expect(subject.processing?).to be true
    end

    it 'can move from processing to completed' do
      subject.trigger
      subject.complete
      expect(subject.completed?).to be true
    end

    it 'can move from processing to errored' do
      subject.trigger
      subject.error
      expect(subject.errored?).to be true
    end
  end

  describe '#should_deactivate?' do
    context 'when dispatch_at is in the past' do
      before do
        subject.dispatch_at = DateTime.now.in_time_zone.beginning_of_minute - 3.days
      end

      it 'should be true for only active events' do
        expect(subject.should_deactivate?).to be true

        subject.deactivate!
        expect(subject.should_deactivate?).to be false

        subject.reactivate!
        subject.trigger!
        expect(subject.should_deactivate?).to be false
      end
    end

    context 'when dispatch_at is in the future' do
      before do
        subject.dispatch_at = DateTime.now.in_time_zone.beginning_of_minute + 3.days
      end

      it 'should be false' do
        expect(subject.should_deactivate?).to be false
      end
    end
  end

  describe '#should_reactivate?' do
    context 'when dispatch_at is in the past' do
      before do
        subject.dispatch_at = DateTime.now.in_time_zone.beginning_of_minute - 3.days
      end

      it 'should be false' do
        expect(subject.should_reactivate?).to be false
      end
    end

    context 'when dispatch_at is in the future' do
      before do
        subject.dispatch_at = DateTime.now.in_time_zone.beginning_of_minute + 3.days
      end

      it 'should be true for only active events' do
        expect(subject.should_reactivate?).to be false

        subject.deactivate!
        expect(subject.should_reactivate?).to be true

        subject.reactivate!
        subject.trigger!
        expect(subject.should_reactivate?).to be false
      end
    end
  end

  describe '#trigger[!]' do
    it 'can not be called from an inactive state' do
      subject.state = 'inactive'
      expect { subject.trigger }.to raise_exception(AASM::InvalidTransition)
      expect { subject.trigger! }.to raise_exception(AASM::InvalidTransition)
    end

    it 'can not be called from a completed state' do
      subject.state = 'completed'
      expect { subject.trigger }.to raise_exception(AASM::InvalidTransition)
      expect { subject.trigger! }.to raise_exception(AASM::InvalidTransition)
    end

    it 'can not be called from an errored state' do
      subject.state = 'errored'
      expect { subject.trigger }.to raise_exception(AASM::InvalidTransition)
      expect { subject.trigger! }.to raise_exception(AASM::InvalidTransition)
    end

    it 'can not be called from a processing state' do
      subject.state = 'processing'
      expect { subject.trigger }.to raise_exception(AASM::InvalidTransition)
      expect { subject.trigger! }.to raise_exception(AASM::InvalidTransition)
    end
  end

  describe '#send_email' do
    before do
      subject.name = 'Pre-due Reminder'
      subject.state = 'processing'
      allow_any_instance_of(TahiStandardTasks::ReviewerMailer).to receive(:remind_before_due)
    end

    it 'should error if the email cannot be sent' do
      subject.send_email
      expect(subject.state).to eq('errored')
    end

    it 'should complete if the email is sent' do
      subject.due_datetime = DueDatetime.create! due_at: DateTime.now.utc - 1.day
      subject.send_email
      expect(subject.state).to eq('completed')
    end
  end
end
