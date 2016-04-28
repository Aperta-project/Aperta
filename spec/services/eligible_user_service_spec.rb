require 'rails_helper'

describe EligibleUserService, pristine_roles_and_permissions: true do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }

  let(:internal_editor_role) do
    FactoryGirl.create(
      :role,
      name: Role::INTERNAL_EDITOR_ROLE,
      journal: journal
    )
  end

  let(:bob) { FactoryGirl.create(:user, first_name: 'Bob') }
  let(:fay) { FactoryGirl.create(:user, first_name: 'Fay') }

  describe '.eligible_for?' do
    subject(:is_eligible) do
      EligibleUserService.eligible_for?(
        paper: paper,
        role: role,
        user: user
      )
    end
    let(:eligible_users) { [bob] }
    let(:role) { FactoryGirl.build_stubbed(:role) }

    before do
      allow(EligibleUserService).to receive(:new)
        .with(paper: paper, role: role)
        .and_return instance_double(
          EligibleUserService,
          eligible_users: eligible_users
        )
    end

    context 'when the user is eligible for the role on the given paper' do
      it 'returns true 'do
        expect(
          EligibleUserService.eligible_for?(
            paper: paper,
            role: role,
            user: bob
          )
        ).to be(true)
      end
    end

    context 'when the user is not eligible for the on the given paper' do
      it 'returns true 'do
        expect(
          EligibleUserService.eligible_for?(
            paper: paper,
            role: role,
            user: fay
          )
        ).to be(false)
      end
    end
  end

  describe '.eligible_users_for' do
    before do
      bob.assignments.create(role: internal_editor_role, assigned_to: journal)
      fay.assignments.create(role: internal_editor_role, assigned_to: journal)
    end

    it 'returns eligible_users from a newly constructed EligibleUserService' do
      role = FactoryGirl.build_stubbed(:role)

      expect(EligibleUserService).to receive(:new)
        .with(paper: paper, role: role)
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

    context "and the role matches the journal's academic_editor_role" do
      let(:role) do
        FactoryGirl.create(
          :role,
          name: Role::ACADEMIC_EDITOR_ROLE,
          journal: journal
        )
      end
      let(:random_role) do
        FactoryGirl.create(
          :role,
          name: 'Some Random Role',
          journal: journal
        )
      end
      let(:ray) { FactoryGirl.create(:user, first_name: 'Ray') }

      before do
        ray.assignments.create(role: random_role, assigned_to: journal)
      end

      it 'returns all users in the system regardless of role' do
        expect(service.eligible_users).to contain_exactly(bob, fay, ray)
      end

      it "doesn't include users already assigned as academic_editor_role" do
        fay.assignments.create(role: role, assigned_to: paper)
        expect(service.eligible_users).to_not include(fay)
      end

      it 'supports fuzzy matching on the user' do
        expect(service.eligible_users(matching: 'Bob')).to contain_exactly(bob)
        expect(service.eligible_users(matching: 'Fay')).to contain_exactly(fay)
        expect(service.eligible_users(matching: 'Ray')).to contain_exactly(ray)
      end
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

      it "doesn't include users already assigned as cover_editor_role" do
        fay.assignments.create(role: role, assigned_to: paper)
        expect(service.eligible_users).to_not include(fay)
      end

      it 'supports fuzzy matching on the user' do
        expect(service.eligible_users(matching: 'Bob')).to contain_exactly(bob)
        expect(service.eligible_users(matching: 'Fay')).to contain_exactly(fay)
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
      let(:jane) { FactoryGirl.create(:user, first_name: 'Jane') }
      let(:freelance_role) do
        FactoryGirl.create(
          :role,
          name: Role::FREELANCE_EDITOR_ROLE,
          journal: journal
        )
      end

      before do
        jane.assignments.create(role: freelance_role, assigned_to: journal)
      end

      it "returns the users who have the journal's internal_editor_role" do
        expect(service.eligible_users).to include(bob, fay)
      end

      it "returns the users who have the journal's freelance_editor_role" do
        expect(service.eligible_users).to include(jane)
      end

      it "doesn't include users already assigned as handling_editor_role" do
        fay.assignments.create(role: role, assigned_to: paper)
        expect(service.eligible_users).to_not include(fay)
      end

      it 'supports fuzzy matching on the user' do
        expect(service.eligible_users(matching: 'Bob')).to contain_exactly(bob)
        expect(service.eligible_users(matching: 'Fay')).to contain_exactly(fay)
        expect(service.eligible_users(matching: 'Jane')).to contain_exactly(jane)
      end
    end

    context 'and the role is unsupported for finding eligible users' do
      let(:role) { FactoryGirl.create(:role, name: 'Unsupported') }

      it 'raises an exception' do
        expect do
          service.eligible_users
        end.to raise_error(NotImplementedError, /Don't know how to find/)
      end
    end
  end
end
