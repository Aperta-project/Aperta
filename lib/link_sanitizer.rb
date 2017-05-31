# Replaces all anchor links in a text block to their text equivalent`
module LinkSanitizer
  def self.sanitize(text)
    doc = Nokogiri::HTML(text)
    doc.css('a').each do |link|
      if link.attributes['href'].present?
        link.replace('[' + link.text + ' (' +
          link.attributes['href'].value + ')]')
      else
        link.replace(link.text)
      end
    end
    doc.css('table.btn.btn-primary').each do |table|
      table.attributes['class'].value = 'btn'
    end
    doc.to_s
  end
end
