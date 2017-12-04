require 'rails_helper'

describe CustomCard::FinancialDisclosureMigrator do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }
  let(:assigned_user) { FactoryGirl.create(:user) }
  let(:legacy_task) { FactoryGirl.create(:legacy_financial_disclosure_task, :with_loaded_card, paper: paper, phase: phase, assigned_user: assigned_user) }

  # old answers
  let(:legacy_card_content) { legacy_task.card_version.content_root.self_and_descendants }
  let(:legacy_funding_cc) { legacy_card_content.detect { |cc| cc.ident == 'financial_disclosures--author_received_funding' } }
  let!(:received_funding_answer) { FactoryGirl.create(:answer, owner: legacy_task, card_content: legacy_funding_cc) }

  let(:legacy_funder_card) { Card.where(name: "TahiStandardTasks::Funder").first! }
  let(:legacy_funder_content) { legacy_funder_card.latest_card_version.content_root.self_and_descendants }
  let(:legacy_funder_influence_cc) { legacy_funder_content.detect { |cc| cc.ident == 'funder--had_influence' } }
  let(:legacy_funder_influence_description_cc) { legacy_funder_content.detect { |cc| cc.ident == 'funder--had_influence--role_description' } }

  let(:corp_funder) { FactoryGirl.create(:funder, task: legacy_task, name: "Corporate Funder", grant_number: "abc123", website: "http://example.com", additional_comments: "creative accounting paid for this") }
  let(:legacy_corp_funder_influence_answer) { FactoryGirl.create(:answer, owner: corp_funder, card_content: legacy_funder_influence_cc, value: "true") }
  let(:legacy_corp_funder_influence_description_answer) { FactoryGirl.create(:answer, owner: corp_funder, card_content: legacy_funder_influence_description_cc, value: "constant corporate oversight") }
  let(:gov_funder) { FactoryGirl.create(:funder, task: legacy_task, name: "Government Funder", grant_number: "xyz123", website: "http://example.gov", additional_comments: "research results are taxed") }
  let(:legacy_gov_funder_influence_answer) { FactoryGirl.create(:answer, owner: gov_funder, card_content: legacy_funder_influence_cc, value: "true") }
  let(:legacy_gov_funder_influence_description_answer) { FactoryGirl.create(:answer, owner: gov_funder, card_content: legacy_funder_influence_description_cc, value: "constant government oversight") }

  let!(:card) { CustomCard::Loader.load!(CustomCard::Configurations::FinancialDisclosure, journal: journal).first }
  let(:new_task) { Task.where(card_version_id: card.latest_card_version).first! }

  describe "migrate" do
    before do
      CardLoader.load("TahiStandardTasks::Funder")
      legacy_corp_funder_influence_answer # let!
      legacy_corp_funder_influence_description_answer # let!
      legacy_gov_funder_influence_answer # let!
      legacy_gov_funder_influence_description_answer # let!
      subject.migrate_all
    end

    it "creates a new CustomCardTask tied to the Card" do
      expect(new_task).to be_a(CustomCardTask)
      expect(new_task.card_version).to eq(card.latest_card_version)
      expect(new_task.title).to eq(card.name)
    end

    it "copies relevant attributes from the legacy task to the new task" do
      expect(new_task.phase).to eq(legacy_task.phase)
      expect(new_task.completed).to eq(legacy_task.completed)
      expect(new_task.body).to eq(legacy_task.body)
      expect(new_task.position).to eq(legacy_task.position)
      expect(new_task.paper).to eq(legacy_task.paper)
      expect(new_task.completed_at).to eq(legacy_task.completed_at)
      expect(new_task.assigned_user).to eq(legacy_task.assigned_user)
    end

    it "associates the author_received_funding Answer with the new Task" do
      answer = Answer.includes(:card_content).where(card_contents: { ident: 'financial_disclosures--author_received_funding' }).last!
      expect(answer.owner).to eq(new_task)
      expect(answer.card_content.root).to eq(new_task.card_version.content_root)
    end

    it "creates Answers for each Funder attribute" do
      new_funders = Funder.from_task(new_task)
      expect(new_funders.length).to eq(2)

      new_corp_funder = new_funders.first
      expect(new_corp_funder.name).to eq("Corporate Funder")
      expect(new_corp_funder.grant_number).to eq("abc123")
      expect(new_corp_funder.website).to eq("http://example.com")
      expect(new_corp_funder.additional_comments).to eq("creative accounting paid for this")
    end

    it "moves Answers belonging to a Funder to the new Task" do
      new_funders = Funder.from_task(new_task)
      expect(new_funders.length).to eq(2)

      new_corp_funder = new_funders.first
      expect(new_corp_funder.influence).to eq(true)
      expect(new_corp_funder.influence_description).to eq("constant corporate oversight")
    end
  end
end
