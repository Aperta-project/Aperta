class AdministrateJournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def index
    head :ok
  end
end
