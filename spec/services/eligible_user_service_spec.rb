require 'rails_helper'

describe EligibleUserService do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }

  let(:internal_editor_role) do
    FactoryGirl.create(
      :role,
      name: Role::INTERNAL_EDITOR_ROLE,
      journal: journal
    )
  end

  let(:bob) { FactoryGirl.create(:user) }
  let(:fay) { FactoryGirl.create(:user) }

  describe '.eligible_users_for' do
    before do
      bob.assignments.create(role: internal_editor_role, assigned_to: journal)
      fay.assignments.create(role: internal_editor_role, assigned_to: journal)
    end

    it 'returns eligible_users from a newly constructed EligibleUserService' do
      role = FactoryGirl.build_stubbed(:role)

      expect(EligibleUserService).to receive(:new)
        .and_return instance_double(EligibleUserService, eligible_users: [bob])

      eligible_users = EligibleUserService.eligible_users_for(
        paper: paper,
        role: role
      )
      expect(eligible_users).to eq [bob]
    end
  end

  describe '#eligible_users returns eligible users for a paper and role' do
    subject(:service) do
      EligibleUserService.new(paper: paper, role: role)
    end

    before do
      bob.assignments.create(role: internal_editor_role, assigned_to: journal)
      fay.assignments.create(role: internal_editor_role, assigned_to: journal)
    end

    context "and the role matches the journal's cover_editor_role" do
      let(:role) do
        FactoryGirl.create(
          :role,
          name: Role::COVER_EDITOR_ROLE,
          journal: journal
        )
      end

      it "returns the users who have the journal's internal_editor_role" do
        expect(service.eligible_users).to contain_exactly(bob, fay)
      end

      it "doesn't include users assigned to the paper as cover_editor_role" do
        fay.assignments.create(role: role, assigned_to: paper)
        expect(service.eligible_users).to contain_exactly(bob)
      end
    end

    context "and the role matches the journal's handling_editor_role" do
      let(:role) do
        FactoryGirl.create(
          :role,
          name: Role::HANDLING_EDITOR_ROLE,
          journal: journal
        )
      end

      it "returns the users who have the journal's internal_editor_role" do
        expect(service.eligible_users).to contain_exactly(bob, fay)
      end

      it "doesn't include users already assigned as handling_editor_role" do
        fay.assignments.create(role: role, assigned_to: paper)
        expect(service.eligible_users).to contain_exactly(bob)
      end
    end

    context "and the role is unsupported for finding eligible users" do
      let(:role) { FactoryGirl.create(:role, name: 'Unsupported') }

      it 'raises an exception' do
        expect do
          service.eligible_users
        end.to raise_error(NotImplementedError, /Don't know how to find/)
      end
    end
  end
end
