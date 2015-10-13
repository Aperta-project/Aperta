require 'rails_helper'

describe TaskFactory do

  let(:phase) { FactoryGirl.create(:phase) }
  let(:task_klass) {'TahiStandardTasks::ReviseTask'}

  it "Creates a task" do

    tf = TaskFactory.new(task_klass, phase: phase)

    expect {
      tf.create!
    }.to change{ Task.count }.by(1)
  end

  it "Sets the default title and role if is not indicated" do
    tf = TaskFactory.new(task_klass, phase: phase)
    task = tf.create!
    expect(task.title).to eq('Revise Task')
    expect(task.role).to eq('author')
  end

  it "Sets the title from params" do
    tf = TaskFactory.new(task_klass, phase: phase, title: 'Test')
    task = tf.create!
    expect(task.title).to eq('Test')
  end

  it "Sets the role from params" do
    tf = TaskFactory.new(task_klass, phase: phase, role: 'editor')
    task = tf.create!
    expect(task.role).to eq('editor')
  end

  it "Sets the phase to the task" do
    tf = TaskFactory.new(task_klass, phase: phase)
    task = tf.create!
    expect(task.phase).to eq(phase)
  end

  it "Sets the phase to the task from params ID" do
    tf = TaskFactory.new(task_klass, phase_id: phase.id)
    task = tf.create!
    expect(task.phase).to eq(phase)
  end

  it "Sets the body from params" do
    tf = TaskFactory.new(task_klass, phase: phase, body: {key: 'value'})
    task = tf.create!
    expect(task.body).to eq({'key' => 'value'})
  end

  it "Sets the participants from params" do

    participants = [FactoryGirl.create(:user)]

    tf = TaskFactory.new(task_klass, phase: phase, participants: participants)
    task = tf.create!
    expect(task.participants).to eq(participants)
  end

  it "Add the creator as participant in task if is submission type" do
    user = FactoryGirl.create(:user)

    tf = TaskFactory.new(task_klass, phase: phase, creator: user, title: 'Test')
    task = tf.create!
    expect(task.participants).to include(user)
    expect(task.title).to eq('Test')
  end

  it "Avoid duplicate creator as participant if is already there" do
    user = FactoryGirl.create(:user)
    participants = [user]
    options = {phase: phase, creator: user, participants: participants}
    tf = TaskFactory.new(task_klass, options)

    task = tf.create!
    expect(task.participants).to eq(participants)
  end
end
