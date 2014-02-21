require 'spec_helper'

describe FlowManagersController do
  let(:user) { FactoryGirl.create :user, :admin, first_name: "Admin" }

  before do
    sign_in user
  end

  describe "GET 'show'" do
    subject(:do_request) { get :show }
    subject(:do_request_json) { get :show, format: :json }

    specify { expect(do_request).to be_success }
    specify { expect(do_request).to render_template 'show' }

    it_behaves_like "when the user is not signed in"
    it_behaves_like "when the user is not an admin"

    describe "@unassigned_papers" do
      let(:journal) { Journal.create! }
      let!(:paper1) { Paper.create! short_title: 'My paper', journal: journal }
      let!(:paper2) { Paper.create! short_title: 'Another paper', journal: Journal.create! }

      before do
        JournalRole.create! user: user, journal: journal, admin: true
      end

      it "includes papers with Assigned Admin tasks with no assignee" do
        do_request_json
        unassigned_papers = assigns(:flows).first.last.map &:first
        expect(unassigned_papers).to include paper1
      end

      it "does not include unassigned papers from journals the user is not an admin for" do
        do_request_json
        unassigned_papers = assigns(:flows).first.last.map &:first
        expect(unassigned_papers).not_to include paper2
      end
    end
  end
end
