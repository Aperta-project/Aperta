class NestedQuestionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    card = Card.lookup_card(params[:type])
    content = CardContent.where(card: card)
    # Exclude the root node
    content = content.where.not(parent_id: nil)
    render json: content, each_serializer: CardContentAsNestedQuestionSerializer
  end
end
