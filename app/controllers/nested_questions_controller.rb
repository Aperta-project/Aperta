class NestedQuestionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    content = Card.lookup_card(params[:type])
                .latest_content_without_root

    # Exclude the root node
    render json: content, each_serializer: CardContentAsNestedQuestionSerializer
  end
end
