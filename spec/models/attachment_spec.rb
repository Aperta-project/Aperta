require 'rails_helper'

describe Attachment do
  subject(:attachment) do
    FactoryGirl.build(:attachment)
  end

  describe '#owner=' do
    let(:paper) { FactoryGirl.build_stubbed(:paper) }
    let(:task) { FactoryGirl.build_stubbed(:task, paper: paper) }

    it 'sets the #paper when the owner is a Paper' do
      expect do
        attachment.owner = paper
      end.to change(attachment, :paper).to paper
    end

    it 'sets the #paper when the owner responds to #paper' do
      expect do
        attachment.owner = task
      end.to change(attachment, :paper).to task.paper
    end
  end
end
