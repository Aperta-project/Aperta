class Admin::JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def index
    @journals = Journal.all
  end
end
