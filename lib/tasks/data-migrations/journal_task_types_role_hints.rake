namespace :data do
  namespace :migrate do
    namespace :journal_task_types do
      desc 'Sets the Journal Task Type role hints'
      task set_role_hints: :environment do
        Journal.all.each do |journal|
          Task.descendants.each do |klass|
            journal.journal_task_types
                   .where(kind: klass)
                   .update_all(role_hint: klass::DEFAULT_ROLE_HINT)
          end
        end
      end
    end
  end
end
