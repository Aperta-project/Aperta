require 'rails_helper'

describe HtmlSanitizationSnapshotConverter do
  describe '#call' do
    let(:html) { '<div>Some div</div><foo>Some foo</foo>' }
    let(:subject) { HtmlSanitizationSnapshotConverter.new }

    it 'sanitizes the html string' do
      expect(subject.call!(html)).to eq '<div>Some div</div>Some foo'
    end
  end
end
