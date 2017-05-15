require 'rails_helper'

describe PlosBioTechCheck::RevisionTechCheckTask do
  subject(:task) { FactoryGirl.create :revision_tech_check_task, paper: paper }
  let(:paper) do
    FactoryGirl.create(
      :paper,
      :submitted,
      :with_creator,
      journal: journal
    )
  end
  let(:journal){ FactoryGirl.create(:journal, :with_creator_role) }

  describe '.restore_defaults' do
    it_behaves_like '<Task class>.restore_defaults update title to the default'
  end
end
