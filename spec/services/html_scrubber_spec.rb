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

  describe 'doesn\'t strip off list-style-type?' do
    let(:value) { Loofah.fragment('<ol style="list-style-type: lower-greek;"></ol>') }
    it 'list-style-type still remains' do
      value.scrub! subject
      expect(value.to_html).to eq '<ol style="list-style-type: lower-greek;"></ol>'
    end
  end
end
