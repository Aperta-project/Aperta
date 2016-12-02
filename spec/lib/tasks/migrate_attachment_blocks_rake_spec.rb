require 'rails_helper'

describe "migrate attachment blocks rake task" do
  before :all do
    Rake::Task.define_task(:environment)
  end

  subject(:run_rake_task) do
    name = 'data:migrate:migrate_attachment_blocks'
    Rake::Task[name].reenable
    Rake.application.invoke_task name
  end

  let!(:paper) { FactoryGirl.create(:paper) }
  let!(:task) { FactoryGirl.create(:ad_hoc_task, paper: paper, body: body) }
  let(:body) do
    [
      [{ "type" => "text", "value" => "foo" }]
    ]
  end

  context "the task has an attachment" do
    let!(:attachment) { FactoryGirl.create(:adhoc_attachment, owner: task) }
    context "the task body has no attachments block" do
      it "adds the attachments block to the body" do
        run_rake_task
        expect(task.reload.body).to eq(
          [
            [{ "type" => "text", "value" => "foo" }],
            [{ "type" => "attachments", "value" => "Please select a file." }]
          ]
        )
      end
    end
    context "the task body has an attachments block" do
      let(:body) do
        [
          [{ "type" => "text", "value" => "foo" }],
          [{ "type" => "attachments", "value" => "Please select a file." }]
        ]
      end
      it "doesn't affect the task's body" do
        run_rake_task
        expect(task.reload.body).to eq(body)
      end
    end
  end
  context "the task has no attachment" do
    it "doesn't affect the task's body" do
      run_rake_task
      expect(task.reload.body).to eq(body)
    end
  end
end
