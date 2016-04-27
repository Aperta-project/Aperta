require 'rails_helper'

describe PlosBioTechCheck::FinalTechCheckController do
  routes { PlosBioTechCheck::Engine.routes }
  let(:admin) { create :user, :site_admin, first_name: "Admin" }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_integration_journal,
      :submitted,
      creator: admin
    )
  end
  let(:task) { create :final_tech_check_task, paper: paper }

  before do
    task.body["finalTechCheckBody"] = "words"
    sign_in admin
  end

  describe "#letter_text" do
    it "return ITC task.body" do
      expect(subject.letter_text(task)).to eq "words"
    end
  end

  describe "#send_email" do
    it 'makes the paper editable' do
      post :send_email, id: task.id, format: :json
      task.paper.reload
      expect(task.paper.editable).to eq true
    end
  end
end
