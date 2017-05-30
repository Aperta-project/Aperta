require 'rails_helper'
require 'link_sanitizer'

describe 'LinkSanitizer' do
  it 'sanitizes a text block with an href link' do
    text = '<table class="btn btn-primary">hello <a href="http://plos.org">world</a></table>'
    expected_text = '<table class="btn">hello [world (http://plos.org)]</table>'
    expect(LinkSanitizer.sanitize(text)).to include expected_text
    expect(LinkSanitizer.sanitize(text)).to_not include text
  end

  it 'sanitizes a text block with an empty link' do
    text = '<table class="btn btn-primary">hello <a>world</a></table>'
    expected_text = '<table class="btn">hello world</table>'
    expect(LinkSanitizer.sanitize(text)).to include expected_text
    expect(LinkSanitizer.sanitize(text)).to_not include text
  end
end
