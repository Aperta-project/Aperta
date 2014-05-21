class ManuscriptManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  def show
    head :ok
  end

end
