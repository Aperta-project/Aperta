require 'rails_helper'

describe "data:seed_production_instance" do
  before :all do
    Rake::Task.define_task(:environment)
  end

  let :run_rake_task do
    Rake::Task['data:seed_production_instance'].reenable
    Rake.application.invoke_task "data:seed_production_instance"
  end

  it "seeds the environment without errors" do
    expect(Rake::Task['db:schema:load']).to receive(:invoke)
    expect(Rake::Task['data:update_journal_task_types']).to receive(:invoke)
    expect(Rake::Task['journal:create_default_templates']).to receive(:invoke)
    expect(Rake::Task['nested-questions:seed']).to receive(:invoke)

    expect { run_rake_task }.not_to raise_error
    expect(Journal.first).to be_present
  end
end
