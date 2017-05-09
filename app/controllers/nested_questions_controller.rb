# Serves card content as nested questions
class NestedQuestionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    card = Card.find_by(name: LookupClassNamespace.lookup_namespace(params[:type]))
    content = card.try(:content_for_version_without_root, :latest) || []
    # Exclude the root node
    render json: content, each_serializer: CardContentAsNestedQuestionSerializer
  end
end
