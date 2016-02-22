require 'rails_helper'

describe PlosBioTechCheck::InitialTechCheckController do

  let(:admin) { create :user, :site_admin, first_name: "Admin" }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_integration_journal,
      :submitted,
      creator: admin
    )
  end
  let(:task) { create :initial_tech_check_task, paper: paper }

  before do
    @routes = PlosBioTechCheck::Engine.routes
    task.body["initialTechCheckBody"] = "words"
  end

  describe "#letter_text" do
    it "return ITC task.body" do
      expect(subject.letter_text(task)).to eq "words"
    end
  end
end
