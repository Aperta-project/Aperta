# Extend this class to make a migration that calls a rake task, e.g.
#
# ```
# class RunDoSomething < DataMigration
#   RAKE_TASK = 'data:migrate:do_something'
# end
# ```
#
# This will run the specified rake task on a migrate `up` if and only if that
# task exists. If the task no longer exists, it will run nothing. The migration
# will fail on `down`.
#
# This allows data migrations that satisfy the following:
# 1. Automatically run once and only once in a defined order on deploy.
# 2. Can be run again if necessary.
# 3. Can be removed if the code is no longer active/valid (by removing the rake
#    task), while still allowing the migration to succeed (it will be a noop).
class DataMigration < ActiveRecord::Migration
  def up
    fail StandardError, "#{self.class} did not define RAKE_TASK" \
      unless defined? self.class::RAKE_TASK
    return unless Rake::Task.task_defined?(self.class::RAKE_TASK)
    Rake::Task[self.class::RAKE_TASK].invoke
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
