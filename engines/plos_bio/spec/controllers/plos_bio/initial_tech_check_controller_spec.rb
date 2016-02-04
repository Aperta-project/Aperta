require 'rails_helper'

describe PlosBio::InitialTechCheckController do

  let(:admin) { create :user, :site_admin, first_name: "Admin" }
  let(:paper) { FactoryGirl.create(:paper_with_phases, :submitted, creator: admin) }
  let(:task) { create :initial_tech_check_task, paper: paper }

  before do
    @routes = PlosBio::Engine.routes
    task.body["initialTechCheckBody"] = "words"
  end

  describe "#letter_text" do
    it "return ITC task.body" do
      expect(subject.letter_text(task)).to eq "words"
    end
  end
end
