require 'rails_helper'

describe TaskFactory do

  let(:phase) { FactoryGirl.create(:phase) }
  let(:klass) {'TahiStandardTasks::ReviseTask'}

  it "Creates a task" do
    expect {
      TaskFactory.create(klass, phase: phase)
    }.to change{ Task.count }.by(1)
  end

  it "Sets the default title and role if is not indicated" do
    task = TaskFactory.create(klass, phase: phase)
    expect(task.title).to eq('Revise Task')
    expect(task.role).to eq('author')
  end

  it "Sets the title from params" do
    task = TaskFactory.create(klass, phase: phase, title: 'Test')
    expect(task.title).to eq('Test')
  end

  it "Sets the role from params" do
    task = TaskFactory.create(klass, phase: phase, role: 'editor')
    expect(task.role).to eq('editor')
  end

  it "Sets the phase to the task" do
    task = TaskFactory.create(klass, phase: phase)
    expect(task.phase).to eq(phase)
  end

  it "Sets the phase to the task from params ID" do
    task = TaskFactory.create(klass, phase_id: phase.id)
    expect(task.phase).to eq(phase)
  end

  it "Sets the body from params" do
    task = TaskFactory.create(klass, phase: phase, body: {key: 'value'})
    expect(task.body).to eq({'key' => 'value'})
  end

  it "Sets the participants from params" do
    participants = [FactoryGirl.create(:user)]
    task = TaskFactory.create(klass, phase: phase, participants: participants)
    expect(task.participants).to eq(participants)
  end

  it "Add the creator as participant in task if is submission type" do
    user = FactoryGirl.create(:user)
    expect(UserMailer).to receive_message_chain(:delay, :add_participant)
    task = TaskFactory.create(klass, phase: phase, creator: user)
    expect(task.participants).to include(user)
  end

  it 'Add the creator as participant but do not send notification' do
    user = FactoryGirl.create(:user)
    expect(UserMailer).to_not receive(:delay)
    task = TaskFactory.create(klass, phase: phase, creator: user, notify: false)
    expect(task.participants).to include(user)
  end
end
