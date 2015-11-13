#
# This policy controls access to snapshots. It assumes that the snapshot's
# source is a task, and falls back on the task's policy to determine
# permissions.
#
class SnapshotsPolicy < ApplicationPolicy
  primary_resource :snapshot
  allow_params :for_task

  include TaskAccessCriteria

  def index?
    authorized_to_modify_task?
  end

  private

  def task
    if for_task
      for_task
    elsif snapshot.source.is_a?(Task)
      snapshot.source
    else
      fail NotImplementedError, %(
         I don't know how to check authorization to Snapshot
         for #{snapshot.source.inspect}.
         You may need to implement this.).strip_heredoc
    end
  end

  def tasks_policy
    @tasks_policy ||= TasksPolicy.new(
      current_user: current_user,
      resource: task)
  end
end
