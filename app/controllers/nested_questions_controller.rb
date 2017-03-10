# Serves card content as nested questions
class NestedQuestionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    card = Card.lookup_card(RenamespaceClass.lookup(params[:type]))
    content = card.try(:latest_content_without_root) || []
    # Exclude the root node
    render json: content, each_serializer: CardContentAsNestedQuestionSerializer
  end
end
