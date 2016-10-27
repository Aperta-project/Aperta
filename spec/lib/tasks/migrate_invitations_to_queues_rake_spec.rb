require 'rails_helper'

describe "migrate invitations to queues rake task" do
  before :all do
    Rake::Task.define_task(:environment)
  end

  subject(:run_rake_task) do
    Rake::Task['data:migrate:migrate_invitations_to_queues'].reenable
    Rake.application.invoke_task "data:migrate:migrate_invitations_to_queues"
  end

  let!(:paper) { FactoryGirl.create(:paper, :submitted_lite) }

  let(:task) { FactoryGirl.create(:paper_reviewer_task, paper: paper) }

  let(:decision) { paper.decisions.first }

  let(:another_group_1_primary) do
    FactoryGirl.create(:invitation, {
      task: task,
      paper: paper,
      body: 'another_group_1_primary',
      invitation_queue: nil,
      decision: decision
    })
  end

  let(:another_g1_alternate_1) do
    FactoryGirl.create(:invitation, {
      created_at: 3.hours.ago,
      primary: another_group_1_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'another_g1_alternate_1',
      decision: decision
    })
  end

  let(:another_group_2_primary) do
    FactoryGirl.create(:invitation, {
      task: task,
      paper: paper,
      body: 'another_group_2_primary',
      invitation_queue: nil,
      decision: decision
    })
  end

  let(:another_g2_alternate_1) do
    FactoryGirl.create(:invitation, {
      created_at: 3.hours.ago,
      primary: another_group_2_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'another_g2_alternate_1',
      decision: decision
    })
  end

  let(:group_1_primary) do
    FactoryGirl.create(:invitation, {
      created_at: Date.today,
      task: task,
      paper: paper,
      body: 'group_1_primary',
      invitation_queue: nil,
      decision: decision
    })
  end

  let(:g1_alternate_1) do
    FactoryGirl.create(:invitation, {
      created_at: 1.day.ago,
      primary: group_1_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'g1_alternate_1',
      decision: decision
    })
  end

  let(:g1_alternate_2) do
    FactoryGirl.create(:invitation, {
      created_at: 2.days.ago,
      primary: group_1_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'g1_alternate_2',
      decision: decision
    })
  end

  let(:g1_alternate_3) do
    FactoryGirl.create(:invitation, {
      created_at: 3.days.ago,
      primary: group_1_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'g1_alternate_3',
      decision: decision
    })
  end

  let(:group_2_primary) do
    FactoryGirl.create(:invitation, {
      created_at: Date.today - 1.year,
      task: task,
      paper: paper,
      body: 'group_2_primary',
      invitation_queue: nil,
      decision: decision
    })
  end

  let(:g2_alternate_1_sent) do
    FactoryGirl.create(:invitation, :invited, {
      created_at: 4.days.ago,
      primary: group_2_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'g2_alternate_1_sent',
      decision: decision
    })
  end

  let(:g2_alternate_2) do
    FactoryGirl.create(:invitation, {
      created_at: 5.days.ago,
      primary: group_2_primary,
      task: task,
      paper: paper,
      invitation_queue: nil,
      body: 'g2_alternate_2',
      decision: decision
    })
  end

  let(:sent_1) do
    FactoryGirl.create(:invitation, :invited, {
      created_at: 6.days.ago,
      task: task,
      paper: paper,
      body: 'sent_1',
      invitation_queue: nil,
      decision: decision
    })
  end

  let(:sent_2) do
    FactoryGirl.create(:invitation, :invited, {
      created_at: 7.days.ago,
      task: task,
      paper: paper,
      body: 'sent_2',
      invitation_queue: nil,
      decision: decision
    })
  end

  let(:ungrouped_1) do
    FactoryGirl.create(:invitation, {
      created_at: 8.days.ago,
      task: task,
      paper: paper,
      body: 'ungrouped_1',
      invitation_queue: nil,
      decision: decision
    })
  end

  let(:ungrouped_2) do
    FactoryGirl.create(:invitation, {
      created_at: 9.days.ago,
      task: task,
      paper: paper,
      body: 'ungrouped_2',
      invitation_queue: nil,
      decision: decision
    })
  end

  let(:ungrouped_3) do
    FactoryGirl.create(:invitation, {
      created_at: 10.days.ago,
      task: task,
      paper: paper,
      body: 'ungrouped_3',
      invitation_queue: nil,
      decision: decision
    })
  end

  let(:create_invitations) do
    group_1_primary # create invitations
    g1_alternate_1
    g1_alternate_2
    g1_alternate_3
    group_2_primary
    g2_alternate_1_sent
    g2_alternate_2
    sent_1
    sent_2
    ungrouped_1
    ungrouped_2
    ungrouped_3
  end

  context 'with existing decisions on a paper' do
    before do
      InvitationQueue.destroy_all
      create_invitations
      randomized_positions = (1..12).to_a.shuffle
      Invitation.all.each do |invitation|
        invitation.update_column(:position, randomized_positions.pop)
      end
    end

    it 'creates an invite queue for each decision' do
      run_rake_task
      puts decision.invitation_queue.invitations.pluck(:body, :position)
      expect(InvitationQueue.count).to eq(Decision.count)
      expect(decision.invitation_queue.invitations.pluck(:id)).to contain_exactly(*decision.invitations.pluck(:id))
    end

    it 'sorts the first grouped primary on top if its primary was most recently created' do
      Invitation.destroy_all
      another_group_1_primary
      another_group_2_primary
      another_g2_alternate_1
      # Group1 alternate is last added
      FactoryGirl.create(:invitation, {
        primary: another_group_1_primary,
        task: task,
        paper: paper,
        body: 'last_group_1_alternate',
        invitation_queue: nil,
        decision: decision
      })

      run_rake_task
      expect(InvitationQueue.last.invitations.order(:position).first).to eq(another_group_1_primary)
    end

    it 'sorts the second grouped primary on top if its primary was most recently created' do
      Invitation.destroy_all
      another_group_1_primary
      another_group_2_primary
      another_g1_alternate_1
      # Group2 alternate is last added
      FactoryGirl.create(:invitation, {
        primary: another_group_2_primary,
        task: task,
        paper: paper,
        body: 'last_group_2_alternate',
        invitation_queue: nil,
        decision: decision
      })

      run_rake_task
      expect(InvitationQueue.last.invitations.order(:position).first).to eq(another_group_2_primary)
    end

    it 'sorts stuff by groups, then by sent/unsent, then by creation date' do
      run_rake_task

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
