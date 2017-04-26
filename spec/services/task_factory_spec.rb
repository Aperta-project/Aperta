require 'rails_helper'

describe TaskFactory do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }
  let(:klass) { TahiStandardTasks::ReviseTask }

  before do
    CardLoader.load("TahiStandardTasks::ReviseTask")
  end

  it "Creates a task" do
    expect do
      TaskFactory.create(klass, paper: paper, phase: phase)
    end.to change { Task.count }.by(1)
  end

  it "calls the task's task_added_to_paper hook" do
    expect_any_instance_of(klass).to receive(:task_added_to_paper)
    TaskFactory.create(klass, paper: paper, phase: phase)
  end

  it "Sets the default title if is not indicated" do
    task = TaskFactory.create(klass, paper: paper, phase: phase)
    expect(task.title).to eq('Response to Reviewers')
  end

  it "Sets the title from params" do
    task = TaskFactory.create(klass, paper: paper, phase: phase, title: 'Test')
    expect(task.title).to eq('Test')
  end

  it "Sets the phase on the task" do
    task = TaskFactory.create(klass, paper: paper, phase: phase)
    expect(task.phase).to eq(phase)
  end

  it "Sets the paper on the task" do
    task = TaskFactory.create(klass, paper: paper, phase: phase)
    expect(task.paper).to eq(paper)
  end

  it "Sets the phase to the task from params ID" do
    task = TaskFactory.create(klass, paper: paper, phase_id: phase.id)
    expect(task.phase).to eq(phase)
  end

  it "Sets the phase to the task from params paper_id" do
    task = TaskFactory.create(klass, paper_id: paper.id, phase: phase)
    expect(task.paper).to eq(paper)
  end

  it "Sets the body from params" do
    task = TaskFactory.create(klass, paper: paper, phase: phase, body: { key: 'value' })
    expect(task.body).to eq('key' => 'value')
  end

  it "Sets the participants from params" do
    paper.update(journal: FactoryGirl.create(:journal, :with_roles_and_permissions))
    participants = [FactoryGirl.create(:user)]
    task = TaskFactory.create(klass, paper: paper, phase: phase, participants: participants)
    expect(task.participants).to eq(participants)
  end

  describe "setting task's card version" do
    context "the card version is passed in" do
      let(:card_version) { FactoryGirl.create(:card_version) }
      it "assigns the card version to the task" do
        task = TaskFactory.create(klass, paper: paper, phase: phase, card_version: card_version)
        expect(task.card_version).to eq(card_version)
      end
    end

    context "the card version is not present in the options" do
      let(:klass) { TahiStandardTasks::UploadManuscriptTask }

      context "a card with a matching name as the task exists" do
        let!(:existing_card) do
          FactoryGirl.create(:card, :versioned, name: klass.name, journal: nil)
        end

        it "uses the latest version of that card" do
          task = TaskFactory.create(klass, paper: paper, phase: phase)
          expect(task.card_version).to eq(existing_card.latest_card_version(:latest))
        end
      end
    end
  end

  context "roles and permissions exist" do
    let(:journal) { create :journal }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:phase) { FactoryGirl.create(:phase, paper: paper) }
    let(:klass) { PlosBilling::BillingTask }

    before do
      CardLoader.load("PlosBilling::BillingTask")
    end

    let(:journal_task_type) do
      journal.journal_task_types.find_by(kind: klass.to_s)
    end
    let!(:expected_permissions) do
      [:view, :edit].map do |action|
        Permission.ensure_exists(action, applies_to: klass)
      end
    end

    it "Sets default permissions from the journal_task_type" do
      task_type_perms = journal_task_type.required_permissions
      expect(task_type_perms).to include(*expected_permissions)
      task = TaskFactory.create(klass, paper: paper, phase: phase)
      expect(task.required_permissions).to include(*expected_permissions)
    end
  end

  context "roles and permissions do not exist" do
    let(:journal) { create :journal }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:phase) { FactoryGirl.create(:phase, paper: paper) }
    let(:card_version) { FactoryGirl.create(:card_version) }
    let(:klass) { CustomCardTask }

    it "does not set permissions" do
      task = TaskFactory.create(klass, card_version: card_version, paper: paper, phase: phase)
      expect(task.required_permissions).to be_empty
    end
  end
end
