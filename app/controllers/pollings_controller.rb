class PollingsController < ApplicationController
  def show
    render json: updated_tasks, meta: {time: Time.now.utc, action: "updated"}, root: :tasks
  end

  def updated_tasks
    tasks.where("tasks.updated_at > ?", params[:time])
  end

  def new_tasks
    tasks.where("tasks.created_at > ?", params[:time])
  end

  def id
    Journal.all.pluck(:id).find {|id| params[:stream] == EventStream.name(id) }
  end

  def tasks
    Task.joins(:phase => { :paper => :journal})
      .where("journals.id = ?", id)
  end
end
