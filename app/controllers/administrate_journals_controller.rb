class AdministrateJournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  respond_to :json

  def index
    respond_with Journal.all
  end
end
