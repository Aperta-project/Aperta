Tahi::Application.config.ihat_supported_formats = nil
module IhatSupportedFormats
  def self.call
    if ENV['IHAT_URL'].present?
      begin
        response = Faraday.get(ENV['IHAT_URL'])
        if response && response.body
          Tahi::Application.config.ihat_supported_formats =
            JSON.dump(JSON.parse(response.body))
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
