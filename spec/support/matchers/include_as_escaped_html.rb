# This custom matcher is helpful when you're searching for text in html that
# might be escaped.
# For example: Dr O'Keefe becomes Dr O&#39;Keefe
# This matcher allows you to to keep the text you're searching for unescaped.
# Usage:
#   expect(html).to include_as_escaped_html("Dr O'Keefe")

RSpec::Matchers.define :include_as_escaped_html do |expected_raw|
  match do |actual|
    expected = expected_raw.html_safe? ?
      expected_raw
      : CGI::escapeHTML(expected_raw)

    actual.include? expected
  end
end
