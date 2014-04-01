class OxgarageParser

  def self.parse(filename)
    new(filename).to_hash
  end

  def initialize(filename)
    @filename = filename
  end

  def output
    request = RestClient::Request.new(
          :method => :post,
          :url => 'http://ec2-54-193-185-100.us-west-1.compute.amazonaws.com:8080/ege-webservice/Conversions/docx%3Aapplication%3Avnd.openxmlformats-officedocument.wordprocessingml.document/TEI%3Atext%3Axml/xhtml%3Aapplication%3Axhtml%2Bxml/',
          :payload => {
            :multipart => true,
            :file => File.new(@filename, 'rb')
          })
    response = request.execute

    return response if extract_filename(response.headers).ends_with? 'html'

    extract_document_from response
  end

  def extract_document_from response
    central_directory = Zip::CentralDirectory.read_from_stream StringIO.new(response)
    document_entry = central_directory.detect { |e| e.name.ends_with? 'html' }
    document_entry.get_input_stream.read
  end

  def title
    Nokogiri::HTML(output).css('.stdheader + *').text
  end

  def body
    body = Nokogiri::HTML(output).css('body')
    body.css('.stdheader').remove
    body.css('body > *:first-child').remove
    body.inner_html
  end

  def to_hash
    { title: title, body: body }
  end

  private

  def extract_filename response_headers
    response_headers[:content_disposition].split('filename=').last.chomp('"')
  end

end
