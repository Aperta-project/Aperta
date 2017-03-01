PDFKit.configure do |config|
  config.wkhtmltopdf = if RUBY_PLATFORM =~ /darwin/
                         Rails.root.join('bin', 'wkhtmltopdf').to_s
                       else
                         Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s
                       end

  config.default_options = {
    # We use javascript to render MathML. If there are problems with MathML
    # rendering, maybe try increasing this?
    javascript_delay: 10_000, # milliseconds
    cache_dir: File.join(Dir.tmpdir, 'wkhtmltopdf-cache'),
    page_size: 'Letter',
    load_error_handling: 'ignore',
    load_media_error_handling: 'ignore',
    encoding: 'utf8'
  }
  config.verbose = true
end
