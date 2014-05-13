class EventStreamsController < ApplicationController
  before_action :authenticate_user!
  def show
    render json: EventStream.connection_info(ids).to_json
  end

  def ids
    Journal.joins(papers: :user).where('users.id = ?', current_user.id).uniq.pluck(:id)
  end
end
