class Api::JournalsController < ApplicationController
  def index
    @journals = Journal.all
    render json: @journals, each_serializer: Api::JournalSerializer
  end
end
