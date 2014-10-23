shared_examples_for "administrator for task" do
  it "can modify everything" do
    expect(policy.edit?).to be(true)
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.upload?).to be(true)
  end
end

shared_examples_for "person who can edit but not create a task" do
  it "can modify except create" do
    expect(policy.edit?).to be(true)
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(true)
    expect(policy.upload?).to be(true)
  end
end

shared_examples_for "person who cannot see a task" do
  it "can do nothing" do
    expect(policy.edit?).to be(false)
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.upload?).to be(false)
  end
end
