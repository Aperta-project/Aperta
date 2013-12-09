require 'spec_helper'

describe SubmissionsController do

  let :user do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
  end

  let(:paper) { user.papers.create! short_title: 'paper-for-submission' }

  before { sign_in user }

  describe "GET 'new'" do
    subject(:do_request) { get :new, paper_id: paper.to_param }

    it_behaves_like "when the user is not signed in"

    it { should be_success }

    it "assigns paper" do
      do_request
      assigns(:paper).should eq(paper)
    end
  end

  describe "POST 'create'" do
    subject(:do_request) { post :create, paper_id: paper.to_param }

    it_behaves_like "when the user is not signed in"

    it { should redirect_to root_path }

    it "submits the paper" do
      expect { do_request }.to change { paper.reload.submitted? }.from(false).to(true)
    end

    it "renders a flash notice" do
      do_request
      expect(flash[:notice]).to eq 'Your paper has been submitted to PLOS'
    end

  end
end
