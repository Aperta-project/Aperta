Tahi::Application.config.ihat_supported_formats = 'null'
module IhatSupportedFormats
  def self.call
    # TODO use ENV.fetch; is there ever a time they wouldn't want to use iHat?
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

if Rails.env.test?
  json = %q{
    {
      "import_formats":[
        {"format":"docx","url":"https://tahi.example.com/import/docx",
        "description":"This converts from HTML to Office Open XML"},
        {"format":"odt","url":"https://tahi.example.com/import/odt",
        "description":"This converts from HTML to ODT"}
      ], "export_formats":[
        {"format":"docx","url":"https://tahi.example.com/export/docx",
        "description":"This converts from docx to HTML"},
        {"format":"latex","url":"https://tahi.example.com/export/latex",
        "description":"This converts from latex to HTML"}
      ]
    }
  }
  Tahi::Application.config.ihat_supported_formats = json
else
  IhatSupportedFormats.call
end
