if ENV['IHAT_URL']
  begin
    Tahi::Application.config.ihat_supported_formats = Faraday.get(ENV['IHAT_URL']).body
  rescue Faraday::ConnectionFailed
    Rails.logger.warn "Unable to connect to #{ENV['IHAT_URL']}"
  end
else
  Rails.logger.warn "ENV['IHAT_URL'] Not set, falling back to default document types…"
end
