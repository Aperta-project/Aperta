require 'rails_helper'

module PlosBilling
  describe BillingTask do
    let(:billing_task) { FactoryGirl.create(:billing_task) }

    describe '.restore_defaults' do
      it_behaves_like '<Task class>.restore_defaults update title to the default'
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
