class NestedQuestionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    content = Card.lookup_card(params[:type])
                  .content_for_version(:latest)
                  .where.not(parent_id: nil)

    # Exclude the root node
    render json: content, each_serializer: CardContentAsNestedQuestionSerializer
  end
end
