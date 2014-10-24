# tasks
shared_examples_for "administrator for task" do
  it "can modify everything" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.upload?).to be(true)
  end
end

shared_examples_for "person who can edit but not create a task" do
  it "can modify except create" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(true)
    expect(policy.upload?).to be(true)
  end
end

shared_examples_for "person who cannot see a task" do
  it "can do nothing" do
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.upload?).to be(false)
  end
end

# papers
shared_examples_for "administrator for paper" do
  it "lets them do everything except keep the paper open" do
    expect(policy.edit?).to be(true)
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.upload?).to be(true)
    expect(policy.download?).to be(true)
    expect(policy.heartbeat?).to be(false)
    expect(policy.toggle_editable?).to be(true)
    expect(policy.submit?).to be(true)
  end
end

shared_examples_for "author for paper" do
  it "lets them do everything except keep the paper open and toggle edit mode" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.edit?).to be(true)
    expect(policy.upload?).to be(true)
    expect(policy.download?).to be(true)
    expect(policy.heartbeat?).to be(false)
    expect(policy.toggle_editable?).to be(false)
    expect(policy.submit?).to be(true)
  end
end

shared_examples_for "person who cannot see a paper" do
  it "only lets them create a new paper" do
    expect(policy.edit?).to be(false)
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(false)
    expect(policy.upload?).to be(false)
    expect(policy.download?).to be(false)
    expect(policy.heartbeat?).to be(false)
    expect(policy.toggle_editable?).to be(false)
    expect(policy.submit?).to be(false)
  end
end

# collaborations
shared_examples_for "person who can edit a paper's collaborators" do
  it "lets them create and destroy collaborators" do
    expect(policy.create?).to be(true)
    expect(policy.destroy?).to be(true)
  end
end

shared_examples_for "person who cannot edit a paper's collaborators" do
  it "lets them create and destroy collaborators" do
    expect(policy.create?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end

#participations
shared_examples_for "person who can edit a tasks's participants" do
  it "lets them create and destroy participants" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.destroy?).to be(true)
  end
end

shared_examples_for "person who cannot edit a tasks's participants" do
  it "lets them create and destroy participants" do
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end
