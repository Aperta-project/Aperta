shared_context 'rake helper', rake_test: true do
  let(:task_args) { [] }
  let(:run_rake_task) do
    Rake::Task[task_name].reenable
    Rake::Task[task_name].invoke(*task_args)
  end

  # This needs to be used for stubbing out top-level methods in a rake task,
  # e.g. `open`
  let(:rake_object) { TOPLEVEL_BINDING.eval "self" }
end
