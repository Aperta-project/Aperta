PDFKit.configure do |config|
  config.wkhtmltopdf = if Rails.env.development? &&
                          RUBY_PLATFORM.match(/darwin/)
                         Rails.root.join('bin', 'wkhtmltopdf').to_s
                       else
                         Rails.root.join('bin', 'wkhtmltopdf-linux-amd64').to_s
                       end

  config.default_options = { page_size: 'Letter' }
end
