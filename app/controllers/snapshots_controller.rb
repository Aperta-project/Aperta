class SnapshotsController < ApplicationController
  before_action :authenticate_user!
  # before_action :enforce_policy

  respond_to :json

  def index
    snapshots = Snapshot.where(source_id: params[:task_id], source_type: "Task")
    respond_with snapshots
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
