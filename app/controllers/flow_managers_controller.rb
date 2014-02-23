class FlowManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def show
    respond_to do |format|
      format.html
      format.json do
        @flows = FlowManagerData.new(current_user).flows
      end
    end
  end
end
