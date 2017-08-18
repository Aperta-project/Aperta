module RestrictAccess
  extend ActiveSupport::Concern

  included do
    before_action :restrict_access

    private

    def restrict_access
      authenticate_or_request_with_http_token do |token, _options|
        ApiKey.exists?(access_token: token)
      end
    end
  end
end
