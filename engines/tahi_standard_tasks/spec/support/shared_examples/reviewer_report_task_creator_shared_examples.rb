RSpec.shared_examples_for 'creating a reviewer report task' do |reviewer_report_type:|
  context "assigning reviewer old_role" do
    context "with no existing reviewer" do
      it "creates a ReviewerReportTask" do
        expect {
          subject.process
        }.to change { reviewer_report_type.count }.by(1)
      end

      it 'creates new assignments' do
        expect { subject.process }.to change { Assignment.count }.by(3)
      end

      it 'assigns the user as a Participant on the Paper' do
        subject.process
        expect(
          Assignment.find_by(
            user: assignee,
            role: paper.journal.reviewer_role,
            assigned_to: paper
          )
        ).to be
      end

      it 'assigns the user as a Participant on the task' do
        subject.process
        task = reviewer_report_type.last
        expect(
          Assignment.find_by(
            user: assignee,
            role: paper.journal.task_participant_role,
            assigned_to: task
          )
        ).to be
      end

      it 'assigns the user as a Reviewer Report Owner on the task' do
        subject.process
        task = reviewer_report_type.last
        expect(
          Assignment.find_by(
            user: assignee,
            role: paper.journal.reviewer_report_owner_role,
            assigned_to: task
          )
        ).to be
      end
    end

    context "with an existing reviewer" do
      before do
        FactoryGirl.create(:user).tap do |reviewer|
          reviewer.assignments.create!(
            assigned_to: originating_task,
            role: paper.journal.reviewer_role
          )
        end
      end

      it "creates a #{reviewer_report_type}" do
        expect {
          subject.process
        }.to change { reviewer_report_type.count }.by(1)
      end
    end
  end

  context "with existing #{reviewer_report_type} for User" do
    before do
      subject.process
      reviewer_report_type.first.update(completed: true)
    end

    it "finds the existing task" do
      expect {
        subject.process
      }.to change { reviewer_report_type.count }.by(0)
    end

    it "uncompletes and unsubmits the task" do
      ReviewerReportTaskCreator.new(
        originating_task: originating_task,
        assignee_id: assignee.id
      ).process
      expect(reviewer_report_type.count).to eq 1
      expect(reviewer_report_type.first.completed).to eq false
      expect(reviewer_report_type.first.submitted?).to eq false
    end
  end

  it "adds the assignee as a participant to the task" do
    subject.process
    task = paper.tasks_for_type(reviewer_report_type.name).first
    expect(task.participants).to match_array([assignee])
  end

  context 'when assigning a new reviewer' do
    it 'sends the welcome email' do
      expect(TahiStandardTasks::ReviewerMailer).to \
        receive_message_chain('delay.welcome_reviewer')
      subject.process
    end
  end
end
