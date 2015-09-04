require 'rails_helper'

describe AssignmentsController, type: :controller do
  let(:admin) { create :user, :site_admin }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let!(:role) { FactoryGirl.create(:role, journal: journal) }

  before do
    sign_in(admin)
  end

  describe "GET 'index'" do
    before do
      @paper_role = PaperRole.create! role: role.name, user: admin, paper: paper
    end

    context "when the paper id is provided" do
      expect_policy_enforcement

      it "returns all of the paper roles for the paper" do
        get :index, paper_id: paper.id
        expect(res_body["assignments"]).to include({"id" => @paper_role.id,
                                                                     "created_at" => kind_of(String),
                                                                     "role" => role.name,
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
    expect_policy_enforcement
    let(:assignee) { FactoryGirl.create(:user) }
    let(:admin) { create :user, :site_admin }
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let!(:role) { FactoryGirl.create(:role, journal: journal) }

    it "creates an assignment between a given role and the user for the paper" do
      assignment_attributes = {"role" => role.name, "user_id" => admin.id, "paper_id" => paper.id }
      post :create, "assignment" => assignment_attributes
      expect(res_body["assignment"]).to include(assignment_attributes)
    end

    it "creates an activity" do
      assignment_attributes = {"role" => role.name, "user_id" => assignee.id, "paper_id" => paper.id }
      activity = {
        subject: paper,
        message: "#{assignee.full_name} was added as #{role.name.capitalize}"
      }
      expect(Activity).to receive(:create).with(hash_including(activity))

      post :create, "assignment" => assignment_attributes
    end

  end

  describe "DELETE 'destroy'" do
    expect_policy_enforcement

    let(:admin) { create :user, :site_admin }
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper) { FactoryGirl.create(:paper, journal: journal) }
    let!(:role) { FactoryGirl.create(:role, journal: journal) }

    before do
      @paper_role = PaperRole.create! role: role.name, user: admin, paper: paper
    end

    it "destroys an assignment" do
      delete :destroy, id: @paper_role.id
      expect(res_body["assignment"]).to include({"id" => @paper_role.id,
                                                                   "role" => role.name,
                                                                   "paper_id" => paper.id,
                                                                   "user_id" => admin.id})
    end
  end
end
