require 'rails_helper'

describe InviteQueue do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }
  let(:queue) do
    q = FactoryGirl.create(:invite_queue,
                       invitations: [FactoryGirl.create(:invitation, task: task, paper: paper),
                                     FactoryGirl.create(:invitation, task: task, paper: paper)])
    q.invitations.all.each_with_index do |i, idx|
      i.update(position: idx + 1)
    end
    q
  end

  describe "#add_invite" do
    let(:invitation) { FactoryGirl.create(:invitation, task: task, paper: paper) }
    it 'should add the invitation to the bottom of the queue' do
      queue.add_invite(invitation)
      expect(invitation.invite_queue).to eq(queue)
      expect(invitation.reload.position).to eq(3)
    end
  end

  let(:group_1_primary) do
    FactoryGirl.create(:invitation, task: task, paper: paper, body: 'group_1_primary')
  end

  let(:g1_alternate_1) do
    FactoryGirl.create(:invitation, primary: group_1_primary, task: task, paper: paper, body: 'g1_alternate_1')
  end

  let(:g1_alternate_2) do
    FactoryGirl.create(:invitation, primary: group_1_primary, task: task, paper: paper, body: 'g1_alternate_2')
  end

  let(:g1_alternate_3) do
    FactoryGirl.create(:invitation, primary: group_1_primary, task: task, paper: paper, body: 'g1_alternate_3')
  end

  let(:group_2_primary) do
    FactoryGirl.create(:invitation, task: task, paper: paper, body: 'group_2_primary')
  end

  let(:g2_alternate_1_sent) do
    FactoryGirl.create(:invitation, :invited, primary: group_2_primary, task: task, paper: paper, body: 'g2_alternate_1_sent')
  end

  let(:g2_alternate_2) do
    FactoryGirl.create(:invitation, primary: group_2_primary, task: task, paper: paper, body: 'g2_alternate_2')
  end

  let(:sent_1) { FactoryGirl.create(:invitation, :invited, task: task, paper: paper, body: 'sent_1') }
  let(:sent_2) { FactoryGirl.create(:invitation, :invited, task: task, paper: paper, body: 'sent_2') }

  let(:ungrouped_1) { FactoryGirl.create(:invitation, task: task, paper: paper, body: 'ungrouped_1') }
  let(:ungrouped_2) { FactoryGirl.create(:invitation, task: task, paper: paper, body: 'ungrouped_2') }
  let(:ungrouped_3) { FactoryGirl.create(:invitation, task: task, paper: paper, body: 'ungrouped_3') }

  let(:full_queue) do
    q = FactoryGirl.create(
      :invite_queue,
      invitations: [
        group_1_primary, # 1
        g1_alternate_1, # 2
        g1_alternate_2, # 3  <--- For some reason position 2 again?
        g1_alternate_3, # 4
        group_2_primary, # 5
        g2_alternate_1_sent, # 6
        g2_alternate_2, # 7
        sent_1, # 8
        sent_2, # 9
        ungrouped_1, # 10
        ungrouped_2, # 11
        ungrouped_3  # 12
      ]
    )
    q.invitations.all.each_with_index do |i, idx|
      i.update(position: idx + 1)
    end
    q
  end

  describe "#valid_positions_for_invite" do
    it "an ungrouped primary can go to the position of other ungrouped primaries" do
      expect(full_queue.valid_positions_for_invite(ungrouped_1)).to eq([10, 11])
      expect(full_queue.valid_positions_for_invite(ungrouped_2)).to eq([9, 11])
    end

    it "an alternate can go to the position of another unsent alternate in its group" do
      expect(full_queue.valid_positions_for_invite(g1_alternate_1)).to eq([3, 4])
      expect(full_queue.valid_positions_for_invite(g1_alternate_2)).to eq([2, 4])
      expect(full_queue.valid_positions_for_invite(g2_alternate_2)).to eq([])
    end

    it "a grouped primary has no valid positions" do
      expect(full_queue.valid_positions_for_invite(group_1_primary)).to eq([])
    end

    it "sent (invited) invites have no valid positions" do
      expect(full_queue.valid_positions_for_invite(sent_1)).to eq([])
    end
  end

  describe "#assign_primary" do
    context "the invite is an ungrouped primary" do
      it "places the primary at the top of the queue" do
        full_queue.assign_primary(invite: ungrouped_1, primary: ungrouped_2)
        expect(ungrouped_2.position).to eq(1)
      end
    end

    context "the invite is an alternate" do

    end

    context "the invite is a primary with alternates" do

    end
  end

  describe "#unassign_primary" do

  end

  describe "#remove_invite" do
    context "the invite is an ungrouped primary" do

    end

    context "the invite is an alternate" do

    end

    context "the invite is a primary with alternates" do

    end
  end
end
