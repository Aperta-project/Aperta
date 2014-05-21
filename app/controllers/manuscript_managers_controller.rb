class ManuscriptManagersController < ApplicationController

  def show
    if ManuscriptManagerPolicy.new.can_show?
      head :ok
    else
      head :forbidden
    end
  end

end
