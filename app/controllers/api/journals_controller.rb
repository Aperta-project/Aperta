class Api::JournalsController < ApplicationController
  include RestrictAccess

  def index
    @journals = Journal.all
    render json: @journals, each_serializer: Api::JournalSerializer
  end
end
