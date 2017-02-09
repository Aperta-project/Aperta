# Feature flags represent partially finished features, which are
# concealed in production. Feature flags cannot be created nor
# destroyed by the API; only toggled.
#
class FeatureFlagsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  respond_to :json

  def index
    render json: FeatureFlag.to_hash
  end

  def update
    # must have site admin permission
    raise AuthorizationError unless current_user.site_admin?

    feature_flag.update(feature_flag_params)
    respond_with feature_flag
  end

  private

  def feature_flag
    @feature_flag ||= FeatureFlag.find(params[:name])
  end

  def feature_flag_params
    params.require(:feature_flag).permit(
      :active
    )
  end
end
