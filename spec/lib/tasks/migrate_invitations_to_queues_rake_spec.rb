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

  def create_invitation(invitation_attrs)
    new_attrs = invitation_attrs.merge(task: task,
                                       paper: paper,
                                       invitation_queue: nil,
                                       decision: decision)
    FactoryGirl.create(:invitation, new_attrs)
  end

  let(:another_group_1_primary) { create_invitation(body: 'another_group_1_primary') }
  let(:another_g1_alternate_1) { create_invitation(created_at: 3.hours.ago, primary: another_group_1_primary, body: 'another_g1_alternate_1') }
  let(:another_group_2_primary) { create_invitation(body: 'another_group_2_primary') }
  let(:another_g2_alternate_1) { create_invitation(created_at: 3.hours.ago, primary: another_group_2_primary, body: 'another_g2_alternate_1') }
  let(:group_1_primary) { create_invitation(created_at: 1.year.ago, body: 'group_1_primary') }
  let(:g1_alternate_1) { create_invitation(created_at: 1.day.ago, primary: group_1_primary, body: 'g1_alternate_1') }
  let(:g1_alternate_2) { create_invitation(created_at: 2.days.ago, primary: group_1_primary, body: 'g1_alternate_2') }
  let(:g1_alternate_3) { create_invitation(created_at: 3.days.ago, primary: group_1_primary, body: 'g1_alternate_3') }
  let(:group_2_primary) { create_invitation(created_at: 1.hour.ago, body: 'group_2_primary') }
  let(:g2_alternate_1_sent) { create_invitation(created_at: 4.days.ago, primary: group_2_primary, state: 'invited', invited_at: 1.year.ago, body: 'g2_alternate_1_sent') }
  let(:g2_alternate_2) { create_invitation(created_at: 5.days.ago, primary: group_2_primary, body: 'g2_alternate_2') }
  let(:sent_1) { create_invitation(created_at: 6.days.ago, state: 'invited', invited_at: 6.months.ago, body: 'sent_1') }
  let(:sent_2_rescinded) { create_invitation(created_at: 7.days.ago, state: 'rescinded', invited_at: 6.weeks.ago, body: 'sent_2_rescinded') }
  let(:ungrouped_1) { create_invitation(created_at: 8.days.ago, body: 'ungrouped_1') }
  let(:ungrouped_2) { create_invitation(created_at: 9.days.ago, body: 'ungrouped_2') }
  let(:ungrouped_3) { create_invitation(created_at: 10.days.ago, body: 'ungrouped_3') }

  let(:create_invitations) do
    ungrouped_1
    ungrouped_2
    ungrouped_3
    sent_1
    sent_2_rescinded
    group_1_primary # create invitations
    g1_alternate_1
    g1_alternate_2
    g1_alternate_3
    group_2_primary
    g2_alternate_1_sent
    g2_alternate_2
  end

  context 'with existing decisions on a paper' do
    before do
      InvitationQueue.destroy_all
    end

    it 'creates an invite queue for each decision' do
      create_invitations
      run_rake_task
      expect(InvitationQueue.count).to eq(Decision.count)
      expect(decision.invitation_queue.invitations.pluck(:id)).to contain_exactly(*decision.invitations.pluck(:id))
    end

    it 'sorts the first grouped primary on top if its primary was most recently created' do
      create_invitations
      another_group_1_primary
      another_group_2_primary
      another_g2_alternate_1
      # Group1 alternate is last added
      FactoryGirl.create(:invitation, primary: another_group_1_primary,
                                      task: task,
                                      paper: paper,
                                      body: 'last_group_1_alternate',
                                      invitation_queue: nil,
                                      decision: decision)

      run_rake_task
      expect(InvitationQueue.last.invitations.order(:position).first).to eq(another_group_1_primary)
    end

    it 'sorts the second grouped primary on top if its primary was most recently created' do
      create_invitations
      another_group_1_primary
      another_group_2_primary
      another_g1_alternate_1
      # Group2 alternate is last added
      FactoryGirl.create(:invitation, primary: another_group_2_primary,
                                      task: task,
                                      paper: paper,
                                      body: 'last_group_2_alternate',
                                      invitation_queue: nil,
                                      decision: decision)

      run_rake_task
      expect(InvitationQueue.last.invitations.order(:position).first).to eq(another_group_2_primary)
    end

    it 'sorts stuff by groups, then by sent/unsent, then by creation date from newest to oldest' do
      create_invitations
      randomized_positions = (1..12).to_a.shuffle
      Invitation.all.each do |invitation|
        invitation.update_column(:position, randomized_positions.pop)
      end

      run_rake_task

      expect(group_1_primary.reload.position).to eq(1) # this is the oldest primary
      expect(g1_alternate_1.reload.position).to eq(2) # this is the newest alternate
      expect(g1_alternate_2.reload.position).to eq(3)
      expect(g1_alternate_3.reload.position).to eq(4)
      expect(group_2_primary.reload.position).to eq(5) # this is the newest primary
      expect(g2_alternate_1_sent.reload.position).to eq(6) # this is an older alternate
      expect(g2_alternate_2.reload.position).to eq(7)

      expect(sent_1.reload.position).to eq(8)
      expect(sent_2_rescinded.reload.position).to eq(9)
      expect(ungrouped_3.reload.position).to eq(10)
      expect(ungrouped_2.reload.position).to eq(11)
      expect(ungrouped_1.reload.position).to eq(12)
    end
  end
end
