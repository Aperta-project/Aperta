class FlowManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def show
    @incomplete_tasks = Task.assigned_to(current_user).incomplete.group_by { |t| t.paper }.to_a
    @complete_tasks = Task.assigned_to(current_user).completed.map do |task|
      [task.paper, [task]]
    end
  end
end
