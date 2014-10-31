require 'spec_helper'

describe Task do
  let(:paper) { FactoryGirl.create :paper, :with_tasks }

  describe "default_scope" do
    it "orders so the completed ones are below the incomplete ones" do
      completed_task = Task.create! title: "Paper Admin",
        completed: true,
        role: 'admin',
        phase: paper.phases.first

      incomplete_task = Task.create! title: "Reviewer Report",
        completed: false,
        role: 'reviewer',
        phase: paper.phases.first

      expect(Task.all.map(&:completed).last).to eq(true)

      task = Task.first
      task.update! completed: true
      expect(Task.first).to_not eq(task)
    end
  end

  describe ".without" do
    let!(:tasks) do
      2.times.map do
        Task.create! title: "Paper Admin",
          completed: true,
          role: 'admin',
          phase_id: 3
      end
    end

    it "excludes task" do
      expect(Task.count).to eq(2)
      expect(Task.without(tasks.last).count).to eq(1)
    end
  end

  describe "authorize_update?" do
    let(:paper) { double('paper') }
    let(:user)  { build(:user, site_admin: admin) }
    let(:authorized) { task.authorize_update?(nil, user) }
    before do
      allow(task).to receive(:paper).and_return paper
      allow(paper).to receive(:submitted?).and_return paper_submitted
    end

    context "a non-metadata task with a submitted paper" do
      let(:task) { Task.new(type: 'Task') }
      let(:paper_submitted) { true }
      let(:admin) { false }

      it 'generally returns true' do
        expect(authorized).to eq(true)
      end
    end

    context "a metadata task" do
      class AMetadataTask < Task
        include MetadataTask
      end

      let(:task) { AMetadataTask.new(type: 'AMetadataTask') }

      context 'the paper has been submitted' do
        let(:paper_submitted) { true }

        context "the user is an admin" do
          let(:admin) { true }
          it 'always allows admins' do
            expect(authorized).to eq(true)
          end
        end

        context "the user is not an admin" do
          let(:admin) { false }
          it "doesn't allow a regular user" do
            expect(authorized).to eq(false)
          end
        end
      end

      context 'the paper has not been submitted' do
        let(:paper_submitted) { false }
        let(:admin) { false }
        it "allows a regular user" do
          expect(authorized).to eq(true)
        end
      end
    end
  end
end
