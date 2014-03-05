class UserSettingsController < ApplicationController
  before_filter :authenticate_user!

  def update
    settings = UserSettings.where(user: current_user).first_or_initialize
    settings_params = params.permit(flows: []).reverse_merge!(flows: [])
    settings.update settings_params
    head :no_content
  end
end
