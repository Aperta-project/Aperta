class UserSettingsController < ApplicationController
  before_filter :authenticate_user!

  def update
    settings = UserSettings.where(user: current_user).first_or_initialize
    settings_params = params.permit(flows: []).reverse_merge!(flows: [])
    settings_params[:flows].concat(settings.flows.push(params[:flow_title])) if params[:flow_title].present?
    settings.update settings_params
    head :no_content
  end
end
