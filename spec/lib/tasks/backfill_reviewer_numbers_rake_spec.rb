require 'rails_helper'

describe "backfill reviewer numbers rake task" do
  before :all do
    Rake::Task.define_task(:environment)
  end

  subject(:run_rake_task) do
    name = 'data:migrate:backfill_reviewer_numbers'
    Rake::Task[name].reenable
    Rake.application.invoke_task name
  end


  context "paper with reviewer report tasks" do
    let!(:paper) { FactoryGirl.create(:paper) }
    let(:user) { FactoryGirl.create(:user) }
    let!(:task1) do
      FactoryGirl.create(
        :reviewer_report_task,
        paper: paper,
        title: "Review by Steve"
      )
    end
    let!(:task2) do
      FactoryGirl.create(
        :reviewer_report_task,
        paper: paper,
        title: "Review by Dave"
      )
    end
    context "tasks have activity records for completion" do
      before do
        FactoryGirl.create(:activity,
                           user: user,
                           subject: paper,
                           activity_key: "task.completed",
                           created_at: 1.day.ago,
                           message: "Review by Dave card was marked completed")
        FactoryGirl.create(:activity,
                           user: user,
                           subject: paper,
                           created_at: 1.year.ago,
                           activity_key: "task.completed",
                           message: "Review by Steve card was marked completed")
      end
      context "tasks have no reviewer numbers" do
        it "adds reviewer numbers and changes titles based on the date the activity was created" do
          run_rake_task
          expect(task1.reload.title).to eq("Review by Steve (#1)")
          expect(task2.reload.title).to eq("Review by Dave (#2)")
          expect(task1.reload.body).to eq({"reviewer_number" => 1})
          expect(task2.reload.body).to eq({"reviewer_number" => 2})
        end
      end

      it "is not meant to work if any tasks have existing reviewer numbers" do
        task1.update!(body: {"reviewer_number" => 1})
        expect { run_rake_task }.to raise_error(StandardError)
      end
    end

    context "task with no activity record" do

    end
    context "task with activity record, not for completion" do

    end
  end
end
