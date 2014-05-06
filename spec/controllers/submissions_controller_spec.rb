require 'spec_helper'

describe SubmissionsController do
  let(:user) { FactoryGirl.create :user }
  let(:paper) { user.papers.create! short_title: 'paper-for-submission', journal: Journal.create! }

  before { sign_in user }

  describe "GET 'new'" do
    subject(:do_request) { get :new, paper_id: paper.to_param }

    it_behaves_like "when the user is not signed in"

    specify { expect(do_request).to be_success }

    it "assigns paper" do
      do_request
      expect(assigns(:paper)).to eq(paper)
    end
  end

  before do
    paper.tasks.metadata.map{ |t| t.update_attribute(:completed, true) }
  end

  describe "POST 'create'" do
    subject(:do_request) { post :create, paper_id: paper.to_param }

    it_behaves_like "when the user is not signed in"

    specify { expect(do_request).to redirect_to root_path }

    it "submits the paper" do
      expect { do_request }.to change { paper.reload.submitted? }.from(false).to(true)
    end

    it "renders a flash notice" do
      do_request
      expect(flash[:notice]).to eq 'Your paper has been submitted to PLOS'
    end

  end
end
