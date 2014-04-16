PDFKit.configure do |config|
  # config.wkhtmltopdf = '/Users/neo/workspace/wkhtmltopdf/bin/wkhtmltopdf'
  config.default_options = {
    :page_size => 'Legal',
    :print_media_type => true
  }
end
