require 'spec_helper'

describe TasksController do
  let :user do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich',
      admin: true
  end

  before { sign_in user }

  describe "GET 'index'" do
    let(:paper) { Paper.create! short_title: "abcd" }

    subject(:do_request) { get 'index', id: paper.to_param }

    it_behaves_like "when the user is not signed in"
    it_behaves_like "when the user is not an admin"

    it "assigns the task manager" do
      do_request
      expect(assigns(:task_manager)).to eq(paper.task_manager)
    end

    it "renders index template" do
      do_request
      expect(response).to render_template(:index)
    end
  end
end
