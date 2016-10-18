require 'rails_helper'

describe PlosBioTechCheck::FinalTechCheckTask do
  subject(:task) { FactoryGirl.create :final_tech_check_task, paper: paper }
  let(:paper) do
    FactoryGirl.create(
      :paper,
      :submitted,
      :with_creator,
      journal: journal
    )
  end
  let(:journal){ FactoryGirl.create(:journal, :with_creator_role) }

  it_behaves_like 'a PlosBioTechCheck that notifies the author of changes'

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
    it_behaves_like '<Task class>.restore_defaults update old_role to the default'
  end
end
