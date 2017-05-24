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
end
