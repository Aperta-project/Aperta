module HTMLHelpers
  def parse_html(html)
    Nokogiri::HTML::DocumentFragment.parse html
  end
end
