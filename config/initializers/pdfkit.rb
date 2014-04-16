PDFKit.configure do |config|
  config.wkhtmltopdf = Rails.root.join("bin", "wkhtmltopdf").to_s
  config.default_options = {
    :page_size => 'Letter'
  }
end
