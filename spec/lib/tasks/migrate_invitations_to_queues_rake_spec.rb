require 'rails_helper'

describe "migrate invitations to queues rake task" do
  before :all do
    Rake::Task.define_task(:environment)
  end

  subject(:run_rake_task) do
    Rake::Task['data:migrate:migrate_invitations_to_queues'].reenable
    Rake.application.invoke_task "data:migrate:migrate_invitations_to_queues"
  end

  context 'with existing decisions on a paper' do
    xit 'creates an invite queue for each decision'
  end
end
