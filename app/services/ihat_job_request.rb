# Models a request for ihat.
class IhatJobRequest
  attr_reader :file

  def initialize(file:, recipe_name:, callback_url: nil, metadata: {})
    @file = file
    @recipe_name = recipe_name
    @callback_url = callback_url
    @metadata = metadata
  end

  def make_options
    { recipe_name: @recipe_name }.tap do |options|
      options[:callback_url] = @callback_url if @callback_url
      options[:metadata] = encrypted_payload if @metadata
    end
  end

  def self.recipe_name(from_format:, to_format:)
    from, to = [from_format, to_format].map(&:to_sym)
    case [from, to]
    when [:doc, :html]
      'doc_to_html'
    when [:docx, :html]
      'docx_to_html'
    when [:html, :docx]
      'html_to_docx'
    else
      fail "Unable to find ihat recipe name for converting '#{from_format}' to '#{to_format}'"
    end
  end

  def self.request_for_epub(epub:, source_url:, metadata: {})
    callback_url = DownloadManuscriptWorker.build_ihat_callback_url(nil)

    TahiEpub::Tempfile.create epub, delete: true do |file|
      request = IhatJobRequest.new(
        file: file,
        recipe_name: ihat_recipe_name(source_url),
        callback_url: callback_url,
        metadata: metadata)
      PaperConverter.post_ihat_job(request)
    end
  end

  def self.ihat_recipe_name(url)
    kind = Pathname.new(URI.parse(url).path).extname.delete(".")
    IhatJobRequest.recipe_name(from_format: kind, to_format: 'html')
  end

  private

  def encrypted_payload
    Verifier.new(@metadata).encrypt(expiration_date: 1.month.from_now)
  end
end
