# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
# task exists. If the task no longer exists, it will run nothing but print a
# warning. If `RAKE_TASK_UP` is undefined, it will fail.
#
# The optional `RAKE_TASK_DOWN` will be run if it exists on the down step.
# Otherwise, the down step will do nothing but print a warning.
#
# This allows data migrations that satisfy the following:
# 1. Automatically run once and only once in a defined order on deploy.
# 2. Can be run again if necessary.
# 3. Can be removed if the code is no longer active/valid (by removing the rake
#    task), while still allowing the migration to succeed (it will be a noop).
class DataMigration < ActiveRecord::Migration
  def up
    unless rake_task_up_defined?
      raise NameError, <<-ERROR.strip_heredoc
        #{self.class}::RAKE_TASK_UP is not defined (or not defined properly). It
        should be a string name of the rake task to be run, e.g.

            RAKE_TASK_UP = 'data:migrate:some-task-here'
      ERROR
    end

    rake_task = self.class::RAKE_TASK_UP
    if Rake::Task.task_defined?(rake_task)
      say("  Running rake task: #{rake_task}")
      Rake::Task[rake_task].invoke(*self.class.task_args)
    else
      Rails.logger.warn <<-EOS.strip_heredoc
        #{rake_task} is not a rake task: migration not run
      EOS
    end
  end

  def down
    return unless rake_task_down_defined?

    rake_task = self.class::RAKE_TASK_DOWN
    if Rake::Task.task_defined?(rake_task)
      say("  Running rake task: #{rake_task}")
      Rake::Task[rake_task].invoke(*self.class.task_args)
    else
      Rails.logger.warn <<-EOS.strip_heredoc
        #{rake_task} is not a rake task: migration not run
      EOS
    end
  end

  def self.with_args(*args)
    @task_args = task_args + args
  end

  def self.task_args
    @task_args || []
  end

  private

  def green(str)
    "\e[32m#{str}\e[0m"
  end

  def rake_task_down_defined?
    defined?(self.class::RAKE_TASK_DOWN) && self.class::RAKE_TASK_DOWN.present?
  end

  def rake_task_up_defined?
    defined?(self.class::RAKE_TASK_UP) && self.class::RAKE_TASK_UP.present?
  end
end
