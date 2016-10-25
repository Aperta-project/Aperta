require 'rails_helper'

describe "migrate invitations to queues rake task" do
  before :all do
    Rake::Task.define_task(:environment)
  end

  subject(:run_rake_task) do
    Rake::Task['data:migrate:migrate_invitations_to_queues'].reenable
    Rake.application.invoke_task "data:migrate:migrate_invitations_to_queues"
  end

  let(:paper) { FactoryGirl.create(:paper, :submitted_lite) }

  let(:task) { FactoryGirl.create(:paper_reviewer_task, paper: paper) }

  let(:decision) { paper.decisions.first }

  let!(:group_1_primary) do
    FactoryGirl.create(:invitation, task: task, paper: paper, body: 'group_1_primary', decision: decision)
  end

  let!(:g1_alternate_1) do
    FactoryGirl.create(:invitation, primary: group_1_primary, task: task, paper: paper, body: 'g1_alternate_1', decision: decision)
  end

  let!(:g1_alternate_2) do
    FactoryGirl.create(:invitation, primary: group_1_primary, task: task, paper: paper, body: 'g1_alternate_2', decision: decision)
  end

  let!(:g1_alternate_3) do
    FactoryGirl.create(:invitation, primary: group_1_primary, task: task, paper: paper, body: 'g1_alternate_3', decision: decision)
  end

  let!(:group_2_primary) do
    FactoryGirl.create(:invitation, task: task, paper: paper, body: 'group_2_primary', decision: decision)
  end

  let!(:g2_alternate_1_sent) do
    FactoryGirl.create(:invitation, :invited, primary: group_2_primary, task: task, paper: paper, body: 'g2_alternate_1_sent', decision: decision)
  end

  let!(:g2_alternate_2) do
    FactoryGirl.create(:invitation, primary: group_2_primary, task: task, paper: paper, body: 'g2_alternate_2', decision: decision)
  end

  let!(:sent_1) { FactoryGirl.create(:invitation, :invited, task: task, paper: paper, body: 'sent_1', decision: decision) }
  let!(:sent_2) { FactoryGirl.create(:invitation, :invited, task: task, paper: paper, body: 'sent_2', decision: decision) }

  let!(:ungrouped_1) { FactoryGirl.create(:invitation, task: task, paper: paper, body: 'ungrouped_1', decision: decision) }
  let!(:ungrouped_2) { FactoryGirl.create(:invitation, task: task, paper: paper, body: 'ungrouped_2', decision: decision) }
  let!(:ungrouped_3) { FactoryGirl.create(:invitation, task: task, paper: paper, body: 'ungrouped_3', decision: decision) }

  context 'with existing decisions on a paper' do
    it 'creates an invite queue for each decision' do
      expect(InvitationQueue.count).to eq(0)

      run_rake_task

      expect(decision.invitation_queue.invitations).to eq(decision.invitations)
    end
  end
end
