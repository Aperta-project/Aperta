require 'net/http'

class OxgarageParser
  def initialize(filename)
    @filename = filename
  end

  def output
    request = RestClient::Request.new(
          :method => :post,
          :url => 'http://ec2-54-193-185-100.us-west-1.compute.amazonaws.com:8080/ege-webservice/Conversions/docx%3Aapplication%3Avnd.openxmlformats-officedocument.wordprocessingml.document/TEI%3Atext%3Axml/xhtml%3Aapplication%3Axhtml%2Bxml/',
          :payload => {
            :multipart => true,
            :file => File.new(Rails.root.join('about_equations.docx'), 'rb')
          })
    response = request.execute

    tempfile = Tempfile.new("current_file", encoding: 'ascii-8bit')
    tempfile.write(response)

    html_file = nil
    Zip::File.open(tempfile) do |zip_file|
      zip_file.each do |entry|
        if entry.name =~ /html/
          html_file = entry.get_input_stream.read
        end
      end
      entry = zip_file.glob('*.html').first
      puts entry.get_input_stream.read
      html_file = entry.get_input_stream.read
    end

    html_file
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

  def self.parse(filename)
    new(filename).to_hash
  end
end
