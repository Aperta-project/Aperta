require 'rails_helper'

describe DueDatetime, type: :model do
  subject(:due_datetime) { FactoryGirl.create(:due_datetime) }

  let(:length_of_time) { 11.days }
  let(:extended_length_of_time) { 21.days }
  let(:target_datetime) do
    DateTime.parse("Sat, 17 Jun 2017 17:24:17 UTC +00:00").in_time_zone('Eastern Time (US & Canada)')
  end
  let(:extended_target_datetime) do
    DateTime.parse("Sat, 27 Jun 2017 17:24:17 UTC +00:00").in_time_zone('Eastern Time (US & Canada)')
  end

  describe "#set" do
    it "finds due_at and originally_due_at nil before it is called" do
      expect(subject.due_at).to be_nil
      expect(subject.originally_due_at).to be_nil
      expect(length_of_time).to receive(:from_now).and_return(target_datetime)

      subject.set(length_of_time: length_of_time)
    end

    it "sets both due_at and originally_due_at the first time it is called" do
      expect(length_of_time).to receive(:from_now).and_return(target_datetime)

      subject.set(length_of_time: length_of_time)

      # due_at
      expect(subject.due_at).not_to be_nil
      expect(subject.due_at).to be_instance_of(ActiveSupport::TimeWithZone)
      expect(subject.due_at.to_s).to eq("2017-06-17 18:00:00 UTC")
      # originally_due_at
      expect(subject.originally_due_at).not_to be_nil
      expect(subject.originally_due_at).to be_instance_of(ActiveSupport::TimeWithZone)
      expect(subject.originally_due_at.to_s).to eq("2017-06-17 18:00:00 UTC")
    end

    it "sets only due_at on subsequent calls" do
      # extended_length_of_time
      expect(length_of_time).to receive(:from_now).and_return(target_datetime)
      expect(extended_length_of_time).to receive(:from_now).and_return(extended_target_datetime)

      # we set it once to the initial due datetime, and then set it to a later date
      subject.set(length_of_time: length_of_time)
      original_value = subject.originally_due_at
      subject.set(length_of_time: extended_length_of_time)

      # due_at
      expect(subject.due_at).not_to be_nil
      expect(subject.due_at).to be_a(ActiveSupport::TimeWithZone)
      expect(subject.due_at.to_s).to eq("2017-06-27 18:00:00 UTC")
      # originally_due_at
      expect(subject.originally_due_at).not_to be_nil
      expect(subject.originally_due_at).to be_a(ActiveSupport::TimeWithZone)
      expect(subject.originally_due_at.to_s).to eq("2017-06-17 18:00:00 UTC")
      expect(subject.originally_due_at).to eq(original_value)
    end
  end

  describe "#set_for" do
    # DueDatetime is not dependent on the implementation of any particular other class
    # so we create a generic class here for testing, and to ensure complete decoupling
    class MiscellaneousClass < ActiveRecord::Base
      has_one :due_datetime, as: :due
      delegate :due_at, :originally_due_at, to: :due_datetime, allow_nil: true
      def set_due_datetime(length_of_time: 10.days)
        DueDatetime.set_for(self, length_of_time: length_of_time)
      end

      # skip the database:
      def save(_validate = true)
        true
      end

      def self.columns
        @columns ||= []
      end
    end

    let(:something) { MiscellaneousClass.new }

    it "calls DueDatetime#set" do
      expect(something.due_at).to be_nil
      expect(something.originally_due_at).to be_nil

      expect_any_instance_of(DueDatetime).to receive(:set)

      # initial setting
      something.set_due_datetime(length_of_time: length_of_time)
    end
  end
end
