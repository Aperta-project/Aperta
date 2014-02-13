require 'spec_helper'

describe FlowManagersController do

  describe "GET 'show'" do
    let :admin do
      User.create! username: 'admin',
        first_name: 'Admin',
        last_name: 'Istrator',
        email: 'admin@example.org',
        password: 'password',
        password_confirmation: 'password',
        affiliation: 'PLOS',
        admin: true
    end

    let(:user) { admin }

    let(:fake_profiles) { double :profiles }
    let(:fake_papers) { double :papers }
    let(:fake_tasks) { double :tasks }

    before do
      fake_query = double :query,
        paper_profiles: fake_profiles,
        papers: fake_papers,
        tasks: fake_tasks

      allow(MyTasksQuery).to receive(:new).with(admin).and_return fake_query
      sign_in admin
    end

    subject(:do_request) { get :show }
    it { should be_success }
    it { should render_template :show }

    it_behaves_like "when the user is not signed in"
    it_behaves_like "when the user is not an admin"

    it "requests tasks for the current user" do
      do_request
      expect(MyTasksQuery).to have_received(:new).with admin
    end

    it "assigns my tasks" do
      do_request
      expect(assigns(:my_tasks)).to eq fake_profiles
    end
  end
end
