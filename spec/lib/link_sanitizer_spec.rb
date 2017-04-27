require 'rails_helper'
require 'link_sanitizer'

describe 'LinkSanitizer' do
  it 'sanitizes a text block' do
    text = '<table class="btn btn-primary">hello <a href="http://plos.org">world</a></table>'
    expected_text = '<table>hello [world (http://plos.org)]</table>'
    expect(LinkSanitizer.sanitize(text)).to include expected_text
    expect(LinkSanitizer.sanitize(text)).to_not include text
  end
end
