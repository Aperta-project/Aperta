require 'spec_helper'

# this test is mostly here as a temporary shim.
# it makes sure that a signed in user will get the payload that the
# javascript part of the task would expect.
# the actual ui behavior is covered in the main app for now.
describe "Paper with a reviewer report task" do
  let(:journal) { FactoryGirl.create :journal }
  let!(:reviewer) { FactoryGirl.create :user }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:task) { FactoryGirl.create(:reviewer_report_task, paper: paper) }

  before do
    paper.paper_roles.create!(user: reviewer, role: PaperRole::COLLABORATOR)
    task.participants << reviewer
    post '/users/sign_in',
         'user[login]' => reviewer.username,
         'user[password]' => 'password'
  end

  it "returns the paper with the included task" do
    get "/papers/#{paper.id}", nil, 'HTTP_ACCEPT' => "application/json"

    body = JSON.parse response.body
    expect(body['paper']['tasks'].first['type']).to eq "ReviewerReportTask"
    expect(body['tasks'].first['type']).to eq "StandardTasks::ReviewerReportTask"
  end
end
