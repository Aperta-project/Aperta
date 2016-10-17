require 'rails_helper'

describe InviteQueue do
  def make_queue(invite_array)
    q = FactoryGirl.create(
      :invite_queue,
      invitations: invite_array
    )
    q.invitations.all.each_with_index do |i, idx|
      i.update(position: idx + 1)
    end
    q
  end

  let(:paper) { FactoryGirl.create(:paper) }
  let(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper) }
  let(:queue) do
    make_queue [FactoryGirl.create(:invitation, task: task, paper: paper),
                FactoryGirl.create(:invitation, task: task, paper: paper)]
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
    make_queue [
      group_1_primary, # 1
      g1_alternate_1, # 2
      g1_alternate_2, # 3
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
  end

  describe "#valid_positions_for_invite" do
    it "an ungrouped primary can go to the position of other ungrouped primaries" do
      expect(full_queue.valid_positions_for_invite(ungrouped_1)).to eq([11, 12])
      expect(full_queue.valid_positions_for_invite(ungrouped_2)).to eq([10, 12])
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

  let(:small_queue) do
    make_queue [
      group_1_primary, # 1
      g1_alternate_1, # 2
      sent_1, # 3
      ungrouped_1, # 4
      ungrouped_2, # 5
    ]
  end

  describe "#assign_primary" do
    context "error cases" do
      it "blows up if the invite is an alternate.  primaries need to be unassigned first" do
        expect { small_queue.assign_primary(invite: g1_alternate_1, primary: ungrouped_1) }
          .to raise_error(ActiveRecord::RecordInvalid)
      end

      it "blows up if the invite is a primary with alternates." do
        expect { small_queue.assign_primary(invite: group_1_primary, primary: ungrouped_1) }
          .to raise_error(ActiveRecord::RecordInvalid)
      end

      it "blows up if the invite is not in a pending state" do
        group_1_primary.update(state: "invited")
        expect { small_queue.assign_primary(invite: group_1_primary, primary: ungrouped_1) }
          .to raise_error(ActiveRecord::RecordInvalid)
      end

      it "blows up if the primary is an alternate" do
        expect { small_queue.assign_primary(invite: ungrouped_1, primary: g1_alternate_1) }
          .to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "the invite and the primary are both ungrouped" do
      it "places the primary and the new alternate below the other existing groups" do
        small_queue.assign_primary(invite: ungrouped_2, primary: ungrouped_1)
        expect(ungrouped_1.reload.position).to eq(3)
        expect(ungrouped_2.reload.position).to eq(4)
      end
    end

    context "the invite is ungrouped, the primary already has alternates" do
      it "places the new alternate below the existing alternates" do
        small_queue.assign_primary(invite: ungrouped_1, primary: group_1_primary)
        expect(ungrouped_1.reload.position).to eq(3)
        expect(group_1_primary.reload.position).to eq(1)
      end
    end
  end

  describe "#unassign_primary" do
    context "error cases" do
      let(:small_queue) do
        make_queue [
          group_1_primary, # 1
          g1_alternate_1, # 2
          ungrouped_1, # 4
        ]
      end
      it "blows up if the invite is a primary with alternates." do
        expect { small_queue.unassign_primary(group_1_primary) }
          .to raise_error(ActiveRecord::RecordInvalid)
      end

      it "blows up if the invite has no primary" do
        expect { small_queue.unassign_primary(ungrouped_1) }
          .to raise_error(ActiveRecord::RecordInvalid)
      end

      it "blows up if the invite is not in a pending state" do
        g1_alternate_1.update(state: "invited")
        expect { small_queue.unassign_primary(g1_alternate_1) }
          .to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "the primary has other alternates" do
      let(:small_queue) do
        make_queue [
          group_1_primary, # 1
          g1_alternate_1, # 2
          g1_alternate_2, # 3
          ungrouped_1, # 4
        ]
      end

      it "unassigns the primary" do
        small_queue.unassign_primary(g1_alternate_1)
        expect(g1_alternate_1.reload.primary).to be_blank
      end

      # TODO: this needs to be based on the created_at date
      it "moves the ungrouped invite to the bottom of the list" do
        small_queue.unassign_primary(g1_alternate_1)
        expect(group_1_primary.reload.position).to eq(1) # the primary should stay put
        expect(g1_alternate_1.reload.position).to eq(4)
      end
    end

    context "the primary has no other alternates" do
      let(:small_queue) do
        make_queue [
          group_1_primary, # 1
          g1_alternate_1, # 2
          ungrouped_1, # 3
        ]
      end

      it "unassigns the primary" do
        small_queue.unassign_primary(g1_alternate_1)
        expect(g1_alternate_1.reload.primary).to be_blank
      end

      # TODO: this needs to be based on the created_at date
      it "moves the newly-ungrouped primary and the ungrouped invite to the bottom of the list" do
        small_queue.unassign_primary(g1_alternate_1)
        expect(group_1_primary.reload.position).to eq(2)
        expect(g1_alternate_1.reload.position).to eq(3)
      end
    end
  end

  describe "#remove_invite" do
    context "the invite is an ungrouped primary" do

    end

    context "the invite is an alternate" do

    end

    context "the invite is a primary with alternates" do

    end
  end

  describe "#send_invite" do

  end
end
