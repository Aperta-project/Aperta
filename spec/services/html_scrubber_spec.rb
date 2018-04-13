# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe HtmlScrubber do
  let(:subject) { HtmlScrubber.new }

  describe 'HTML Scrubber' do
    let(:bad_html) { Loofah.fragment('<script>doNaughtything();</script><div><i>stuff</i><blockquote>quote</blockquote></div>') }
    it 'on scrub' do
      bad_html.scrub! subject
      expected_html = Loofah.fragment('doNaughtything();<div><i>stuff</i>quote</div>')
      expect(bad_html.to_html).to eq expected_html.to_html
    end
  end

  describe '#skip_node?' do
    let(:bad_html) { Loofah.fragment('<style> <!-- someStyle { font: Comic Sans } --> </style>') }
    it 'removes the text node if the previous parent was a style tag' do
      bad_html.scrub! subject
      expect(bad_html.to_html).to eq ''
    end
  end

  describe 'doesn\'t strip off list-style-type' do
    let(:value) { Loofah.fragment('<ol style="list-style-type: lower-greek;"></ol>') }
    it 'tests that the list-style-type attributes remains' do
      value.scrub! subject
      expect(value.to_html).to eq '<ol style="list-style-type: lower-greek;"></ol>'
    end
  end
end
