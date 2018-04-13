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

describe ScheduledEvent do
  before do
    subject { FactoryGirl.create :scheduled_event }
  end

  describe '.state' do
    it 'defaults to active' do
      expect(subject.active?).to be true
    end

    it 'can move from active to inactive' do
      subject.disable
      expect(subject.inactive?).to be true
    end

    it 'can move from inactive to active' do
      subject.disable
      subject.reactivate
      expect(subject.active?).to be true
    end

    it 'can move from active to passive' do
      subject.switch_off
      expect(subject.passive?).to be true
    end

    it 'can move from passive to active' do
      subject.switch_off
      subject.switch_on
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

  describe '#should_disable?' do
    context 'when dispatch_at is in the past' do
      before do
        subject.dispatch_at = DateTime.now.in_time_zone.beginning_of_minute - 3.days
      end

      it 'should be true for only active or passive events' do
        expect(subject.should_disable?).to be true

        subject.disable!
        expect(subject.should_disable?).to be false

        subject.reactivate!
        subject.trigger!
        expect(subject.should_disable?).to be false

        subject.reactivate!
        subject.switch_off!
        expect(subject.should_disable?).to be true
      end
    end

    context 'when dispatch_at is in the future' do
      before do
        subject.dispatch_at = DateTime.now.in_time_zone.beginning_of_minute + 3.days
      end

      it 'should be false' do
        expect(subject.should_disable?).to be false
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

      it 'should be true for only inactive events' do
        expect(subject.should_reactivate?).to be false

        subject.disable!
        expect(subject.should_reactivate?).to be true

        subject.reactivate!
        subject.trigger!
        expect(subject.should_reactivate?).to be false
      end
    end
  end

  describe '#trigger[!]' do
    it 'can only be called from an active state' do
      %w[inactive completed errored processing].each do |non_triggerable_state|
        subject.state = non_triggerable_state
        expect { subject.trigger }.to raise_exception(AASM::InvalidTransition)
        expect { subject.trigger! }.to raise_exception(AASM::InvalidTransition)
      end
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

  describe '#finished?' do
    it 'should be true if state is completed, inactive or errored' do
      subject.state = 'completed'
      expect(subject.finished?).to eq(true)

      subject.state = 'inactive'
      expect(subject.finished?).to eq(true)

      subject.state = 'canceled'
      expect(subject.finished?).to eq(true)

      subject.state = 'errored'
      expect(subject.finished?).to eq(true)
    end

    it 'should be false if state is not completed, not inactive or not errored' do
      subject.state = 'processing'
      expect(subject.finished?).to eq(false)

      subject.state = 'active'
      expect(subject.finished?).to eq(false)
    end
  end
end
