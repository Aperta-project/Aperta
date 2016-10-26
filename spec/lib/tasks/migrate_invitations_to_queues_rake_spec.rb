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
    FactoryGirl.create(:invitation, {
      created_at: Date.today,
      task: task,
      paper: paper,
      body: 'group_1_primary',
      invitation_queue: nil,
      decision: decision
    })
  end

  let!(:g1_alternate_1) do
    FactoryGirl.create(:invitation, {
      primary: group_1_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'g1_alternate_1',
      decision: decision
    })
  end

  let!(:g1_alternate_2) do
    FactoryGirl.create(:invitation, {
      primary: group_1_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'g1_alternate_2',
      decision: decision
    })
  end

  let!(:g1_alternate_3) do
    FactoryGirl.create(:invitation, {
      primary: group_1_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'g1_alternate_3',
      decision: decision
    })
  end

  let!(:group_2_primary) do
    FactoryGirl.create(:invitation, {
      created_at: Date.today - 1.year,
      task: task,
      paper: paper,
      body: 'group_2_primary',
      invitation_queue: nil,
      decision: decision
    })
  end

  let!(:g2_alternate_1_sent) do
    FactoryGirl.create(:invitation, :invited, {
      primary: group_2_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'g2_alternate_1_sent',
      decision: decision
    })
  end

  let!(:g2_alternate_2) do
    FactoryGirl.create(:invitation, {
      primary: group_2_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'g2_alternate_2',
      decision: decision
    })
  end

  let!(:sent_1) do
    FactoryGirl.create(:invitation, :invited, {
      task: task,
      paper: paper,
      body: 'sent_1',
      invitation_queue: nil,
      decision: decision
    })
  end
  let!(:sent_2) do
    FactoryGirl.create(:invitation, :invited, {
      task: task,
      paper: paper,
      body: 'sent_2',
      invitation_queue: nil,
      decision: decision
    })
  end

  let!(:ungrouped_1) do
    FactoryGirl.create(:invitation, {
      task: task,
      paper: paper,
      body: 'ungrouped_1',
      invitation_queue: nil,
      decision: decision
    })
  end
  let!(:ungrouped_2) do
    FactoryGirl.create(:invitation, {
      task: task,
      paper: paper,
      body: 'ungrouped_2',
      invitation_queue: nil,
      decision: decision
    })
  end
  let!(:ungrouped_3) do
    FactoryGirl.create(:invitation, {
      task: task,
      paper: paper,
      body: 'ungrouped_3',
      invitation_queue: nil,
      decision: decision
    })
  end

  context 'with existing decisions on a paper' do
    before do
      InvitationQueue.destroy_all
      run_rake_task
    end

    it 'creates an invite queue for each decision' do
      puts decision.invitation_queue.invitations.pluck(:body, :position)
      expect(InvitationQueue.count).to eq(Decision.count)
      expect(decision.invitation_queue.invitations.pluck(:id)).to contain_exactly(*decision.invitations.pluck(:id))
    end

    it 'sorts stuff by groups, then by sent/unsent, then by creation date' do
      expect(group_1_primary.reload.position).to eq(1)
      expect(g1_alternate_1.reload.position).to eq(2)
      expect(g1_alternate_2.reload.position).to eq(3)
      expect(g1_alternate_3.reload.position).to eq(4)
      expect(group_2_primary.reload.position).to eq(5)
      expect(g2_alternate_1_sent.reload.position).to eq(6)
      expect(g2_alternate_2.reload.position).to eq(7)
      expect(sent_1.reload.position).to eq(8)
      expect(sent_2.reload.position).to eq(9)
      expect(ungrouped_1.reload.position).to eq(10)
      expect(ungrouped_2.reload.position).to eq(11)
      expect(ungrouped_3.reload.position).to eq(12)
    end
  end
end
