require 'spec_helper'

# another shim spec.  These can probably be eliminated entirely.
describe "Paper with a tech check task" do
  let(:user) { create :user }
  let(:paper) { FactoryGirl.create(:paper, user: user, submitted: true) }
  let!(:task) { FactoryGirl.create(:tech_check_task, paper: paper) }

  before do
    assign_journal_role(paper.journal, user, :admin)
    task.participants << user

    post '/users/sign_in',
         'user[login]' => user.username,
         'user[password]' => 'password'
  end

  it "returns the paper with the included task" do
    get "/papers/#{paper.id}", nil, 'HTTP_ACCEPT' => "application/json"

    body = JSON.parse response.body
    expect(body['paper']['tasks'].first['type']).to eq "TechCheckTask"
    expect(body['tasks'].first['type']).to eq "StandardTasks::TechCheckTask"
  end
end
