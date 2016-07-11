# Extend this class to make a migration that calls a rake task, e.g.
#
# ```
# class RunDoSomething < DataMigration
#   RAKE_TASK_UP = 'data:migrate:do_something'
#   RAKE_TASK_DOWN = 'data:migrate:undo_something'
# end
# ```
#
# This will run the specified rake task on a migrate `up` if and only if that
# task exists. If the task no longer exists, it will run nothing. If
# `RAKE_TASK_UP` is undefined, it will fail.
#
# The optional `RAKE_TASK_DOWN` will be run if it exists on the down step.
# Otherwise, the down step will do nothin.
#
# This allows data migrations that satisfy the following:
# 1. Automatically run once and only once in a defined order on deploy.
# 2. Can be run again if necessary.
# 3. Can be removed if the code is no longer active/valid (by removing the rake
#    task), while still allowing the migration to succeed (it will be a noop).
class DataMigration < ActiveRecord::Migration
  def up
    fail StandardError, "#{self.class} did not define RAKE_TASK_UP" \
      unless defined? self.class::RAKE_TASK_UP
    return unless Rake::Task.task_defined?(self.class::RAKE_TASK_UP)
    Rake::Task[self.class::RAKE_TASK_UP].invoke
  end

  def down
    return unless defined? self.class::RAKE_TASK_DOWN
    return unless Rake::Task.task_defined?(self.class::RAKE_TASK_DOWN)
    Rake::Task[self.class::RAKE_TASK_DOWN].invoke
  end
end
