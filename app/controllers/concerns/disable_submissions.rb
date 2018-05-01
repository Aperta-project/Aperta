module DisableSubmissions
  extend ActiveSupport::Concern

  def sign_in_alert
    return unless FeatureFlag['DISABLE_SUBMISSIONS']
    render_to_string(partial: 'shared/disabled_submissions_alert').squish
  end
end
