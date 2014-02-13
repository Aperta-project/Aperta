class FlowManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def show
    query = MyTasksQuery.new(current_user)
    @my_tasks = query.paper_profiles
  end
end
