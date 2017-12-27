require 'rails_helper'

describe TahiStandardTasks::ExportDelivery do
  let!(:paper) do
    FactoryGirl.create(:paper, publishing_state: 'accepted')
  end
  subject(:export_delivery) { FactoryGirl.build(:export_delivery, paper: paper, destination: 'apex') }

  describe 'validations' do
    it 'is valid' do
      expect(export_delivery.valid?).to be(true)
    end

    it 'requires a user' do
      export_delivery.user = nil
      expect(export_delivery.valid?).to be(false)
    end

    it 'requires a paper' do
      export_delivery.paper = nil
      expect(export_delivery.valid?).to be(false)
    end

    it 'requires a paper to be accepted' do
      export_delivery.paper.publishing_state = nil
      expect(export_delivery.valid?).to be(false)
    end

    it 'requires a task' do
      export_delivery.task = nil
      expect(export_delivery.valid?).to be(false)
    end
  end
end
