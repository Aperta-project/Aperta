require 'rails_helper'

feature "Adding correspondence", js: true, sidekiq: :inline! do
  let(:user) { FactoryGirl.create(:user) }
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let!(:correspondence_one) do
    FactoryGirl.create(:correspondence, paper: paper)
  end

  before do
    allow(user).to receive(:can?)
      .with(:manage_workflow, paper)
      .and_return true

    assign_journal_role(journal, user, :admin)
    login_as(user)
    visit "/papers/#{paper.id}/correspondence"
  end

  describe "Correspondence list receives pushed update" do
    let!(:correspondence_two) do
      FactoryGirl.build(:correspondence, paper: paper)
    end

    it "Updates view with new correspondence when db record created" do
      expect(page).to have_css('tbody > tr', count: 1)
      correspondence_two.save!
      expect(page).to have_css('tbody > tr', count: 2)
    end
  end
end
