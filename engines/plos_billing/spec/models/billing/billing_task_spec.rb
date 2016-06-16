require 'rails_helper'

module PlosBilling
  describe BillingTask do
    let(:paper) { FactoryGirl.create(:paper, :with_tasks) }
    let(:billing_task) do
      ::PlosBilling::BillingTask.create!(
        completed: true,
        paper: paper,
        phase: paper.phases.first,
        title: "Billing",
        old_role: "author"
      )
    end

    describe '.restore_defaults' do
      include_examples '<Task class>.restore_defaults update title to the default'
      include_examples '<Task class>.restore_defaults update old_role to the default'
    end

    describe '.create' do
      it "creates it" do
        expect(billing_task).to_not be_nil
      end
    end

    describe '#active_model_serializer' do
      it 'has the proper serializer' do
        expect(billing_task.active_model_serializer).to eq PlosBilling::TaskSerializer
      end
    end
  end
end
