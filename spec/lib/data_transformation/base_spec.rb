require 'rails_helper'
require 'data_transformation/base'

describe DataTransformation::Base do
  subject(:data_transformation) { DataTransformation::Base.new }

  describe "#transform" do
    it "raises a NotImplementedError" do
      expect { data_transformation.send(:transform) }.to raise_error NotImplementedError
    end
  end

  describe "#register_counter" do
    let(:counter_name) { :my_counter }

    it "registers a counter on the Transformation" do
      expect do
        data_transformation.send(:register_counter, counter_name)
      end.to change { data_transformation.counters }
               .from({})
               .to(counter_name => 0)
    end

    it "will not add the same counter twice" do
      expect do
        data_transformation.send(:register_counter, counter_name)
        data_transformation.send(:register_counter, counter_name)
      end.to raise_error DataTransformation::DuplicateCounterError

      expect(data_transformation.counters).to eq(counter_name => 0)
    end
  end

  describe "#increment_counter" do
    let(:counter_name) { :my_counter }

    context "there is a registered counter" do
      before do
        data_transformation.send(:register_counter, counter_name)
      end

      it "increments the named counter" do
        expect do
          data_transformation.send(:increment_counter, counter_name)
        end.to change { data_transformation.counters }
                 .from(counter_name => 0)
                 .to(counter_name => 1)
      end

      describe "incrementing a counter which doesn't exist" do
        it "raises an exception" do
          expect do
            data_transformation.send(:increment_counter, :does_not_exist)
          end.to raise_error DataTransformation::UnknownCounterError
        end
      end
    end
  end

  describe "#log_counters" do
    context "3 counters are registered" do
      let(:counter_names) { [:counter_1, :counter_2, :counter_3] }
      before do
        counter_names.each do |counter_name|
          data_transformation.send(:register_counter, counter_name)
        end
      end

      it "prints all of the registered counters" do
        # The +1 to .log call count is for the **counters** header
        expect(data_transformation).to(
          receive(:log).exactly(counter_names.count + 1).times
        )
        data_transformation.send(:log_counters)
      end
    end
  end

  describe "#call" do
    before do
      allow(data_transformation).to receive(:transform) { FactoryGirl.create :paper }
    end

    it "runs #transformation wrapped in a transaction" do
      expect do
        data_transformation.call
      end.to change { Paper.count }.by 1
    end

    context "dry run is on" do
      before do
        data_transformation.dry_run = true
      end

      specify "the transform rolls back" do
        expect do
          data_transformation.call
        end.not_to change { Paper.count }
      end
    end
  end

  describe "#assert" do
    describe "failed assertions" do
      context "repl_on_failed_assert is true" do
        before do
          data_transformation.repl_on_failed_assert = true
        end

        it "calls binding.pry" do
          expect(data_transformation).to receive(:repl)
          data_transformation.send(:assert, false)
        end
      end

      context "repl_on_failed_assert is false" do
        before do
          data_transformation.repl_on_failed_assert = false
        end

        it "raises an error" do
          expect do
            data_transformation.send(:assert, false)
          end.to raise_error DataTransformation::AssertionFailed
        end
      end
    end
  end
end
