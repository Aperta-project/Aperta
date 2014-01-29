require 'spec_helper'

describe DashboardsController do

  let :user do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
  end

  describe "GET 'index'" do
    subject(:do_request) { get :index }

    it_behaves_like "when the user is not signed in"

    before { sign_in user }

    it { should be_success }
    it { should render_template :index }

    describe "papers" do
      before do
        Paper.create! short_title: 'paper-dashboard', journal: Journal.create!
      end

      let(:paper) { Paper.create! user: user, short_title: 'users-paper-dashboard', journal: Journal.create! }
      let!(:task) { paper.task_manager.phases.first.tasks.create! assignee: user, title: 'Assign Editors', role: 'admin' }

      it "assigns papers and tasks" do
        do_request
        expect(assigns(:papers)).to match_array user.papers
        expect(assigns(:all_submitted_papers)).to_not be
        expect(assigns(:paper_tasks).values.flatten).to include(task)
      end

      context "when the user is an admin" do
        before do
          user.update_attribute(:admin, true)
          Paper.create! submitted: true, short_title: 'submitted-paper-dashboard', journal: Journal.create!
        end

        it "assigns papers" do
          do_request
          expect(assigns(:papers)).to match_array user.papers
          expect(assigns(:all_submitted_papers)).to match_array Paper.submitted
          expect(assigns(:paper_tasks).values.flatten).to include(task)
        end
      end
    end

  end
end
