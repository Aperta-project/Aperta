require 'rails_helper'

describe TaskFactory do

  let(:paper) { FactoryGirl.create(:paper) }
  let(:phase) { FactoryGirl.create(:phase, paper: paper) }
  let(:klass) { TahiStandardTasks::ReviseTask }

  it "Creates a task" do
    expect {
      TaskFactory.create(klass, paper: paper, phase: phase)
    }.to change{ Task.count }.by(1)
  end

  it "Sets the default title and old_role if is not indicated" do
    task = TaskFactory.create(klass, paper: paper, phase: phase)
    expect(task.title).to eq('Revise Task')
    expect(task.old_role).to eq('author')
  end

  it "Sets the title from params" do
    task = TaskFactory.create(klass, paper: paper, phase: phase, title: 'Test')
    expect(task.title).to eq('Test')
  end

  it "Sets the old_role from params" do
    task = TaskFactory.create(klass, paper: paper, phase: phase, old_role: 'editor')
    expect(task.old_role).to eq('editor')
  end

  it "Sets the phase on the task" do
    task = TaskFactory.create(klass, paper: paper, phase: phase)
    expect(task.phase).to eq(phase)
  end

  it "Sets the paper on the task" do
    task = TaskFactory.create(klass, paper: paper, phase: phase)
    expect(task.paper).to eq(paper)
  end

  it "Sets the phase to the task from params ID" do
    task = TaskFactory.create(klass, paper: paper, phase_id: phase.id)
    expect(task.phase).to eq(phase)
  end

  it "Sets the phase to the task from params paper_id" do
    task = TaskFactory.create(klass, paper_id: paper.id, phase: phase)
    expect(task.paper).to eq(paper)
  end

  it "Sets the body from params" do
    task = TaskFactory.create(klass, paper: paper, phase: phase, body: {key: 'value'})
    expect(task.body).to eq({'key' => 'value'})
  end

  it "Sets the participants from params" do
    paper.update(journal: FactoryGirl.create(:journal, :with_roles_and_permissions))
    participants = [FactoryGirl.create(:user)]
    task = TaskFactory.create(klass, paper: paper, phase: phase, participants: participants)
    expect(task.participants).to eq(participants)
  end
end
