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
end
