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

    it 'can move from active to complete' do
      subject.trigger
      expect(subject.complete?).to be true
    end
  end
end
