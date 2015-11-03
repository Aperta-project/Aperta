class SnapshotsController < ApplicationController
  before_action :authenticate_user!
  # before_action :enforce_policy

  respond_to :json

  def index
    task = Task.includes(:snapshots, :paper).find(params[:task_id])
    snapshots = task.snapshots
    latest = SnapshotService.new(task.paper).preview(task)[0]
    latest.id = -task.id
    respond_with snapshots + [latest]
  end

  def hello
  end

  def show
    respond_with snapshot
  end

  private

  def snapshot
    @snapshot ||= begin
      if params[:id].present?
        Snapshot.find(params[:id])
      end
    end
  end

  def enforce_policy
    authorize_action!(snapshot: paper, params: params)
  end
end
