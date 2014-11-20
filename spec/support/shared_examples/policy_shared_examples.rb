# tasks
shared_examples_for "administrator for task" do
  it "can modify everything" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.upload?).to be(true)
    expect(policy.send_message?).to be(true)
  end
end

shared_examples_for "person who can edit but not create a task" do
  it "can modify except create" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(true)
    expect(policy.upload?).to be(true)
    expect(policy.send_message?).to be(true)
  end
end

shared_examples_for "person who cannot see a task" do
  it "can do nothing" do
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.upload?).to be(false)
    expect(policy.send_message?).to be(false)
  end
end

# papers
shared_examples_for "administrator for paper" do
  it "lets them do everything except keep the paper open" do
    expect(policy.edit?).to be(true)
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.manage?).to be(true)
    expect(policy.upload?).to be(true)
    expect(policy.download?).to be(true)
    expect(policy.heartbeat?).to be(false)
    expect(policy.toggle_editable?).to be(true)
    expect(policy.submit?).to be(true)
  end
end

shared_examples_for "author for paper" do
  it "lets them do everything except manage, keep the paper open and toggle edit mode" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.edit?).to be(true)
    expect(policy.manage?).to be(false)
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
    expect(policy.manage?).to be(false)
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
  it "doesn't let them create or destroy collaborators" do
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
  it "doesn't let them view or modify participants" do
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end

# comments
shared_examples_for "person who can comment on a task" do
  it "lets them create and view comments" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
  end
end

shared_examples_for "person who cannot comment on a task" do
  it "lets them do nothing" do
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(false)
  end
end

# manuscript manager templates
shared_examples_for "person who can administer manuscript manager templates" do
  it "lets them perform all CRUD actions" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
  end
end

shared_examples_for "person who cannot administer manuscript manager templates" do
  it "doesn't let them perform any actions" do
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end

# phase templates
shared_examples_for "person who can administer phase templates" do
  it "lets them create, update, or destroy phase templates" do
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
  end
end

shared_examples_for "person who cannot administer phase templates" do
  it "doesn't let them perform any actions" do
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end

# task templates
shared_examples_for "person who can administer task templates" do
  it "lets the perform all CRUD actions" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
  end
end

shared_examples_for "person who cannot administer task templates" do
  it "doesn't allow them to perform any actions" do
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end

# journal roles
shared_examples_for "person who can administer journal roles" do
  it "lets them do all the things" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
  end
end

shared_examples_for "person who cannot administer journal roles" do
  it "doesn't allow them to perform any actions" do
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end

# journal
shared_examples_for "person who can administer the journal" do
  it "lets them perform all the available actions" do
    expect(policy.authorization?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.index?).to be(true)
  end
end

shared_examples_for "person who cannot administer the journal" do
  it "doesn't allow them to perform any actions" do
    expect(policy.authorization?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.index?).to be(false)
  end
end

# questions
shared_examples_for "person who can manage questions" do
  it "lets them perform all the available actions" do
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
  end
end

shared_examples_for "person who cannot manage questions" do
  it "doesn't allow them to perform any actions" do
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end

# question attachments
shared_examples_for "person who can manage question attachments" do
  it "lets them destroy them" do
    expect(policy.destroy?).to be(true)
  end
end

shared_examples_for "person who cannot manage question attachments" do
  it "doesn't let them destroy them" do
    expect(policy.destroy?).to be(false)
  end
end

shared_examples_for "person who can view flow manager" do
  it "allows them to perform any action" do
    expect(policy.index?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
    expect(policy.authorization?).to be(true)
  end
end

shared_examples_for "person who can not view flow manager" do
  it "does not allow them to perform any action" do
    expect(policy.index?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.destroy?).to be(false)
    expect(policy.authorization?).to be(false)
  end
end

shared_examples_for "person who can view role flow manager" do
  it "allows them to perform any action" do
    expect(policy.show?).to be(true)
    expect(policy.create?).to be(true)
    expect(policy.update?).to be(true)
    expect(policy.destroy?).to be(true)
  end
end

shared_examples_for "person who can not view role flow manager" do
  it "allows them to perform any action" do
    expect(policy.show?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end
