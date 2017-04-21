#
# add comments
#
class SimilarityChecksController < ::ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def create
    similarity_check = SimilarityCheck.create!(
      versioned_text: versioned_text
    )
    respond_with(similarity_check)
  end

  private

  def create_params
    @create_params ||= params.require(:similarity_check).permit(:versioned_text_id)
  end

  def versioned_text
    VersionedText.find(create_params[:versioned_text_id])
  end
end
