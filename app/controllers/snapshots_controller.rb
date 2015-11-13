class SnapshotsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:index]
  before_action :enforce_index_policy, only: [:index]

  respond_to :json

  def index
    snapshots = task.snapshots
    latest = SnapshotService.new(task.paper).preview(task)[0]
    latest.id = -task.id
    respond_with snapshots + [latest]
  end

  private

  def snapshot
    @snapshot ||= begin
      if params[:id].present?
        Snapshot.find(params[:id])
      end
    end
  end

  def task
    @task ||= Task.includes(:snapshots, :paper).find(params[:task_id])
  end

  def enforce_index_policy
    authorize_action!(snapshot: nil, for_task: task)
  end

  def enforce_policy
    authorize_action!(snapshot: snapshot, params: params)
  end
end
