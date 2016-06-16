shared_examples '<Task class>.restore_defaults does not update title' do
  let!(:task_class) do
    described_class.name.demodulize.underscore.to_sym
  end
  let!(:task_1) do
    FactoryGirl.create(task_class, title: 'Foo bar', old_role: 'admin')
  end
  let!(:task_2) do
    FactoryGirl.create(task_class, title: 'Baz foo', old_role: 'somebody')
  end

  it 'does not restore the title of any of its instances' do
    expect do
      described_class.restore_defaults
    end.to_not change { [task_1.reload.title, task_2.reload.title] }
  end
end

shared_examples '<Task class>.restore_defaults does not update old_role' do
  let!(:task_class) do
    described_class.name.demodulize.underscore.to_sym
  end
  let!(:task_1) do
    FactoryGirl.create(task_class, title: 'Foo bar', old_role: 'admin')
  end
  let!(:task_2) do
    FactoryGirl.create(task_class, title: 'Baz foo', old_role: 'somebody')
  end

  it 'does not restore the old_role of any of its instances' do
    expect do
      described_class.restore_defaults
    end.to_not change { [task_1.reload.old_role, task_2.reload.old_role] }
  end
end

shared_examples '<Task class>.restore_defaults update title to the default' do
  let!(:task_class) do
    described_class.name.demodulize.underscore.to_sym
  end
  let!(:task_1) do
    FactoryGirl.create(task_class, title: 'Foo bar', old_role: 'admin')
  end
  let!(:task_2) do
    FactoryGirl.create(task_class, title: 'Baz foo', old_role: 'somebody')
  end

  it 'does not restore the title of any of its instances' do
    expect do
      described_class.restore_defaults
    end.to change { [task_1.reload.title, task_2.reload.title] }.to(
      [described_class::DEFAULT_TITLE, described_class::DEFAULT_TITLE]
    )
  end
end

shared_examples '<Task class>.restore_defaults update old_role to the default' do
  let!(:task_class) do
    described_class.name.demodulize.underscore.to_sym
  end
  let!(:task_1) do
    FactoryGirl.create(task_class, title: 'Foo bar', old_role: 'admin')
  end
  let!(:task_2) do
    FactoryGirl.create(task_class, title: 'Baz foo', old_role: 'somebody')
  end

  it 'does not restore the old_role of any of its instances' do
    expect do
      described_class.restore_defaults
    end.to change { [task_1.reload.old_role, task_2.reload.old_role] }.to(
      [described_class::DEFAULT_ROLE, described_class::DEFAULT_ROLE]
    )
  end
end
