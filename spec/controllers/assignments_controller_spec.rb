require 'rails_helper'

describe AssignmentsController, type: :controller do
  let(:user) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }

  describe '#index' do
    subject(:do_request) do
      get :index, format: 'json', paper_id: paper.to_param
    end

    let(:paper_assignments) do
      [
        FactoryGirl.create(:assignment, assigned_to: paper),
        FactoryGirl.create(:assignment, assigned_to: paper)
      ]
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user

        allow(user).to receive(:can?)
          .with(:assign_roles, paper)
          .and_return true

        allow(paper).to receive(:assignments)
          .and_return paper_assignments
      end

      it { responds_with(200) }

      it 'returns users who are eligible to be assigned to the provided role' do
        do_request
        expect(res_body['assignments'].count).to eq(paper_assignments.length)

        ids = res_body['assignments'].map{ |hsh| hsh['id'] }
        expect(ids).to include(paper_assignments.first.id)
      end
    end

    context 'when the user does not have access' do
      before do
        allow(user).to receive(:can?)
          .with(:assign_roles, paper)
          .and_return false
      end

      it { responds_with(403) }
    end
  end

  describe "POST 'create'" do
    subject(:do_request) do
      post(
        :create,
        format: 'json',
        assignment: {
          'role_id' => role.id,
          'user_id' => assignee.id,
          'paper_id' => paper.id
        }
      )
    end
    let(:role) { FactoryGirl.create(:role, journal: journal) }
    let(:assignee) { FactoryGirl.create(:user) }

    before do
      sign_in user
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user

        allow(user).to receive(:can?)
          .with(:assign_roles, paper)
          .and_return true

        allow(EligibleUserService).to receive(:eligible_for?)
          .with(paper: paper, role: role, user: assignee)
          .and_return true
      end

      it { responds_with(200) }

      it 'assigns the user to the role' do
        expect do
          do_request
        end.to change {
          assignee.assignments
            .where(role: role, assigned_to: paper)
            .count
        }.by 1
      end

      it "creates an activity" do
        activity = {
          subject: paper,
          message: "#{assignee.full_name} was added as #{role.name.capitalize}"
        }
        expect(Activity).to receive(:create).with(hash_including(activity))
        do_request
      end

      it 'responds with the newly created assignment' do
        do_request
        attrs = res_body['assignment'].slice(
          'id',
          'assigned_to_id',
          'assigned_to_type',
          'role_id'
        )
        expect(attrs).to eq(
          'id' => assignee.assignments.last.id,
          'assigned_to_id' => paper.id,
          'assigned_to_type' => paper.class.name,
          'role_id' => role.id
        )
      end

      context <<-DESCRIPTION do
        and the role_id does not belong to the paper's journal (which
        would happen if someone tried to maliciously assign a user a role
        on another journal)
      DESCRIPTION
        before do
          role.update(journal_id: 999)
        end

        it { is_expected.to responds_with(404) }
      end

      context <<-DESCRIPTION do
        and the user_id is not for an eligible user for this role which
        would happen if someone tried to maliciously assign a user a role that
        they are not able to fulfill
      DESCRIPTION
        before do
          allow(EligibleUserService).to receive(:eligible_for?)
            .with(paper: paper, role: role, user: assignee)
            .and_return false
        end

        it { is_expected.to responds_with(422) }
      end
    end

    context 'when the user does not have access' do
      before do
        allow(user).to receive(:can?)
          .with(:assign_roles, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe "DELETE 'destroy'" do
    subject(:do_request) do
      delete(
        :destroy,
        format: 'json',
        paper_id: paper.to_param,
        id: assignment.to_param
      )
    end
    let!(:assignment) do
      FactoryGirl.create(
        :assignment,
        assigned_to: paper,
        role: role,
        user: assignee
      )
    end
    let(:role) { FactoryGirl.create(:role, journal: journal) }
    let(:assignee) { FactoryGirl.create(:user) }

    before do
      sign_in user
    end

    it_behaves_like 'an unauthenticated json request'

    context 'when the user has access' do
      before do
        stub_sign_in user

        allow(user).to receive(:can?)
          .with(:assign_roles, paper)
          .and_return true
      end

      it { is_expected.to responds_with(200) }

      it 'destroys the assignment' do
        expect do
          do_request
        end.to change {
          assignee.assignments
            .where(role: role, assigned_to: paper)
            .count
        }.by(-1)

        expect do
          assignment.reload
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'responds with the deleted assignment' do
        do_request
        attrs = res_body['assignment'].slice(
          'id',
          'assigned_to_id',
          'assigned_to_type',
          'role_id'
        )
        expect(attrs).to eq(
          'id' => assignment.id,
          'assigned_to_id' => paper.id,
          'assigned_to_type' => paper.class.name,
          'role_id' => role.id
        )
      end
    end

    context 'when the user does not have access' do
      before do
        allow(user).to receive(:can?)
          .with(:assign_roles, paper)
          .and_return false
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
