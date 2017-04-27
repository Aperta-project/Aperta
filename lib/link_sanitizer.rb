# Replaces all anchor links in a text block to their text equivalent`
module LinkSanitizer
  def self.sanitize(text)
    doc = Nokogiri::HTML(text)
    doc.css('a').each do |link|
      link.replace('[' + link.text + ' (' +
        link.attributes['href'].value + ')]')
    end
    doc.to_s
  end
end
