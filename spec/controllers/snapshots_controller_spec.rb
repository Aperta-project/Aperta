require 'rails_helper'

describe SnapshotsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:paper) { FactoryGirl.create(:paper, :with_integration_journal) }
  let(:task) do
    FactoryGirl.create(:ethics_task, paper: paper, participants: [user])
  end
  let(:preview) { SnapshotService.new(paper).preview(task) }

  before do
    SnapshotService.new(paper).snapshot!(task)
    sign_in user
  end

  describe '#index' do
    subject(:do_request) do
      get :index,
          format: 'json',
          task_id: task.to_param
    end

    it_behaves_like 'an unauthenticated json request'

    it "returns the task's snapshots" do
      do_request
      expect(res_body['snapshots'].count).to eq(2)
      ids = res_body['snapshots'].map { |snapshot| snapshot['id'] }
      expect(ids).to include(task.snapshots[0].id)
    end
  end
end
