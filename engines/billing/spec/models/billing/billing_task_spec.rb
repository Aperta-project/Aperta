require 'rails_helper'

module Billing
  describe Task do
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
    let(:billing_task) do
      ::Billing::Task.create! completed: true,
        phase: paper.phases.first,
        title: "Billing",
        role: "author"
    end
    describe '.create' do
      it "creates it" do
        expect(billing_task).to_not be_nil
      end

    end
    describe '#active_model_serializer' do
      it 'has the proper serializer' do
        expect(billing_task.active_model_serializer).to eq Billing::TaskSerializer
      end
    end

  end
end
