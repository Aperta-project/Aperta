module ApplicationHelper
  def orcid_enabled?(provider)
    Rails.configuration.orcid_enabled == true && provider == :orcid
  end
end
