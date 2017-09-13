require 'rails_helper'

describe JournalServices::CreateDefaultManuscriptManagerTemplates do
  let(:service) { JournalServices::CreateDefaultManuscriptManagerTemplates }
  let(:journal) { FactoryGirl.create(:journal) }

  before do
    # prevent normal after create callback
    allow_any_instance_of(Journal).to receive(:setup_defaults)
    # make sure journal task types are created - required before MMT
    JournalServices::CreateDefaultTaskTypes.call(journal)
  end

  it "creates default manager templates" do
    expect do
      service.call(journal)
    end.to change { journal.manuscript_manager_templates.count } .by(1)
  end

  describe ".create_phase_template" do
    let(:mmt) { FactoryGirl.create(:manuscript_manager_template, journal: journal) }

    it "creates a new phase template with a journal task type" do
      phase_template = service.create_phase_template(
        name: "A New Phase Name",
        journal: journal,
        mmt: mmt,
        phase_content: TahiStandardTasks::EarlyPostingTask
      )

      expect(phase_template.task_templates.length).to eq(1)
      expect(phase_template.task_templates.first.journal_task_type).to be_kind_of(JournalTaskType)
    end

    it "creates a new phase template with a card" do
      phase_template = service.create_phase_template(
        name: "A New Phase Name",
        journal: journal,
        mmt: mmt,
        phase_content: CustomCard::Configurations::Sampler
      )

      expect(phase_template.task_templates.length).to eq(1)
      expect(phase_template.task_templates.first.card).to be_kind_of(Card)
    end
  end
end
