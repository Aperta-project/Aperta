require 'rails_helper'

describe AssignmentsController, type: :controller do
  let(:admin) { create :user, :site_admin }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let!(:old_role) { FactoryGirl.create(:old_role, journal: journal) }

  before do
    sign_in(admin)
  end

  describe "GET 'index'" do
    before do
      @paper_role = PaperRole.create! old_role: old_role.name, user: admin, paper: paper
    end

    context "when the paper id is provided" do
      expect_policy_enforcement

      it "returns all of the paper old_roles for the paper" do
        get :index, paper_id: paper.id
        expect(res_body["assignments"]).to include({"id" => @paper_role.id,
                                                                     "created_at" => kind_of(String),
                                                                     "old_role" => old_role.name,
                                                                     "paper_id" => paper.id,
                                                                     "user_id" => admin.id})
      end
    end

    context "when the paper_id isn't provided" do
      it "returns 404" do
        get :index
        expect(response.status).to eq(404)
      end
    end
  end

  describe "POST 'create'" do
    subject(:do_request) { post :create, 'assignment' => assignment_attributes }

    let(:assignment_attributes) do
      {'old_role' => old_role.name, 'user_id' => assignee.id, 'paper_id' => paper.id }
    end

    let(:assignee) { FactoryGirl.create(:user) }
    let(:admin) { create :user, :site_admin }
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let!(:old_role) { OldRole.where(name: 'Admin').first_or_create! }

    before do
      Role.ensure_exists(Role::HANDLING_EDITOR_ROLE, journal: journal)
      Role.ensure_exists(Role::STAFF_ADMIN_ROLE, journal: journal)
    end

    expect_policy_enforcement

    context 'and the param old_role is Admin' do
      let!(:old_role) { OldRole.where(name: 'Admin').first_or_create! }

      it 'creates an Role.staff_admin assignment' do
        expect { do_request }.to change(assignee.assignments, :count).by(1)
        expect(assignee.assignments.last).to eq \
          Assignment.where(
            user: assignee,
            role: journal.roles.staff_admin,
            assigned_to: paper
          ).first
      end
    end

    context 'and the param old_role is Editor' do
      let!(:old_role) { OldRole.where(name: 'Editor').first_or_create! }

      it 'creates an Role.handling_editor assignment' do
        expect { do_request }.to change(assignee.assignments, :count).by(1)
        expect(assignee.assignments.last).to eq \
          Assignment.where(
            user: assignee,
            role: journal.roles.handling_editor,
            assigned_to: paper
          ).first
      end
    end

    it "creates an assignment between a given old_role and the user for the paper" do
      do_request
      expect(res_body["assignment"]).to include(assignment_attributes)
    end

    it "creates an activity" do
      activity = {
        subject: paper,
        message: "#{assignee.full_name} was added as #{old_role.name.capitalize}"
      }
      expect(Activity).to receive(:create).with(hash_including(activity))
      do_request
    end
  end

  describe "DELETE 'destroy'" do
    subject(:do_request) { delete :destroy, id: paper_role.id }

    let(:assignee) { FactoryGirl.create :user }
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let!(:old_role) do
      OldRole.where(name: old_role_name, journal: journal).first_or_create!
    end
    let!(:old_role_name) { 'Admin' }
    let!(:paper_role) do
      PaperRole.create!(old_role: old_role_name, user: assignee, paper: paper)
    end

    expect_policy_enforcement

    context 'and the paper_role has an staff admin assignment' do
      let!(:old_role_name) { 'Admin' }
      let!(:assignment) do
        Assignment.where(
          user: assignee,
          role: journal.roles.staff_admin,
          assigned_to: paper
        ).first_or_create!
      end

      it 'deletes an Role.staff_admin assignment' do
        expect { do_request }.to change(assignee.assignments, :count).by(-1)
        expect { assignment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'and the paper_role has an handling editor assignment' do
      let!(:old_role_name) { 'Editor' }
      let!(:assignment) do
        Assignment.where(
          user: assignee,
          role: journal.roles.handling_editor,
          assigned_to: paper
        ).first_or_create!
      end

      it 'deletes an Role.staff_admin assignment' do
        expect { do_request }.to change(assignee.assignments, :count).by(-1)
        expect { assignment.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'destroys an the PaperRole assignment (old role)' do
      do_request
      expect(res_body['assignment']).to include({
        'id' => paper_role.id,
        'old_role' => old_role.name,
        'paper_id' => paper.id,
        'user_id' => assignee.id
      })
    end
  end
end
