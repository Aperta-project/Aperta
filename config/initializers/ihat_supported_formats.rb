Tahi::Application.config.ihat_supported_formats = ''
module IhatSupportedFormats
  def self.call
    if ENV['IHAT_URL'].present?
      begin
        response = Faraday.get(ENV['IHAT_URL'])
        is_json = %r{^application/json}.match(response.headers[:content_type])
        if response && is_json
          Tahi::Application.config.ihat_supported_formats =
            JSON.parse(response.body).to_s
        else
          warn "Invalid JSON response from #{ENV['IHAT_URL']}"
        end
      rescue Faraday::ConnectionFailed
        warn "Unable to connect to #{ENV['IHAT_URL']}"
      end
    else
      warn "ENV['IHAT_URL'] Not set, falling back to default document types…"
    end
  end
end

def warn(message)
  Rails.logger.warn message
end

IhatSupportedFormats.call unless Rails.env.test?
