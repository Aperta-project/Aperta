class OxgarageParser

  def self.parse(filename)
    new(File.new(filename, 'rb')).to_hash
  end

  def initialize(file)
    @file = file
  end

  def to_hash
    { title: title, body: body }
  end

  def output
    return @output if @output

    conn = Faraday.new do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    params = {
      properties: properties,
      file: Faraday::UploadIO.new(@file, 'application/octet-stream')
    }

    response = conn.post(url, params)
    if extract_filename(response.headers).ends_with? 'html'
      @output = Nokogiri::HTML(response.body)
    else
      @output = Nokogiri::HTML(extract_document_from(response.body))
    end
  end

  def extract_document_from response
    central_directory = Zip::CentralDirectory.read_from_stream StringIO.new(response)
    document_entry = central_directory.detect { |e| e.name.ends_with? 'html' }
    document_entry.get_input_stream.read
  end

  def title
    output.css('.stdheader + *').text
  end

  def body
    body = output.css('body')
    body.css('.stdheader').remove
    body.css('body > *:first-child').remove
    body.css('.stdfooter').remove
    non_blank_elements = body.children.reject { |e| e.inner_text.blank? }
    Nokogiri::XML::NodeSet.new(body.document, non_blank_elements).to_html.strip
  end

  private

  def url
    ENV.fetch('OXGARAGE_URL')
  end

  def properties
    '<conversions><conversion index="0"><property id="oxgarage.getImages">true</property><property id="oxgarage.getOnlineImages">true</property><property id="oxgarage.lang">en</property><property id="oxgarage.textOnly">false</property><property id="pl.psnc.dl.ege.tei.profileNames">sciencejournal</property></conversion><conversion index="1"><property id="oxgarage.getImages">true</property><property id="oxgarage.getOnlineImages">true</property><property id="oxgarage.lang">en</property><property id="oxgarage.textOnly">false</property><property id="pl.psnc.dl.ege.tei.profileNames">sciencejournal</property></conversion></conversions>'
  end

  def extract_filename response_headers
    response_headers[:content_disposition].split('filename=').last.chomp('"')
  end
end
