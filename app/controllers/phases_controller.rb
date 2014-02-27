class PhasesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @phase = Phase.new(params[:phase])
    if @phase.save
      respond_to do |format|
        format.json { @phase.to_json }
      end
    end
  end
end
