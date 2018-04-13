# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# Models a request for ihat.
class IhatJobRequest
  attr_reader :file
  attr_reader :content_type

  def initialize(file:, recipe_name:, content_type:, callback_url: nil, metadata: {})
    @file = file
    @recipe_name = recipe_name
    @callback_url = callback_url
    @metadata = metadata
    @content_type = content_type
  end

  def make_options
    { recipe_name: @recipe_name }.tap do |options|
      options[:callback_url] = @callback_url if @callback_url
      options[:metadata] = encrypted_payload if @metadata
    end
  end

  def self.recipe_name(from_format:, to_format:)
    # ihat recipe names are case insensitive, but let us be careful
    from, to = [from_format, to_format].map(&:downcase).map(&:to_sym)
    case [from, to]
    when [:doc, :html]
      'doc_to_html'
    when [:docx, :html]
      'docx_to_html'
    when [:html, :docx]
      'html_to_docx'
    else
      raise "Unable to find ihat recipe name for converting '#{from_format}' to '#{to_format}'"
    end
  end

  def self.request_for_epub(epub:, url:, metadata: {})
    callback_url = build_ihat_callback_url
    from_format = Pathname.new(URI.parse(url).path).extname.delete('.')

    TahiEpub::Tempfile.create epub, delete: true do |file|
      request = IhatJobRequest.new(
        file: file,
        recipe_name: recipe_name(from_format: from_format, to_format: 'html'),
        callback_url: callback_url,
        content_type: 'application/epub+zip',
        metadata: metadata)
      PaperConverters::PaperConverter.post_ihat_job(request)
    end
  end

  UrlHelpers = Rails.application.routes.url_helpers

  # +build_ihat_callback_url+ is a utility method for use in a controller
  # context. By default it builds the url using the request object's host and
  # port, but it can be overriden by the `IHAT_CALLBACK_URL` environment
  # variable
  def self.build_ihat_callback_url
    url = ENV.fetch('IHAT_CALLBACK_URL') do
      if TahiEnv.force_ssl?
        protocol = 'https'
        port = 443
      else
        protocol = 'http'
        port = 80
      end

      UrlHelpers.root_url(protocol: protocol, port: port)
    end

    uri = URI.parse(url)
    UrlHelpers.ihat_jobs_url(protocol: uri.scheme, host: uri.host, port: uri.port)
  end

  private

  def encrypted_payload
    Verifier.new(@metadata).encrypt(expiration_date: 1.month.from_now)
  end
end
