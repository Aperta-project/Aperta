require 'rails_helper'
require 'link_sanitizer'

describe 'LinkSanitizer' do
  it 'sanitizes a text block' do
    text = 'hello <a href="http://plos.org">world</a>'
    expected_text = 'hello [world (http://plos.org)]'
    expect(LinkSanitizer.sanitize(text)).to include expected_text
    expect(LinkSanitizer.sanitize(text)).to_not include text
  end
end
