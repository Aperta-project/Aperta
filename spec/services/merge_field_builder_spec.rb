require 'rails_helper'

describe MergeFieldBuilder do
  class SampleContext < TemplateContext
    def self.complex_merge_fields
      [{ name: :foo, context: SecondSampleContext, many: true }]
    end

    def simple
      'so simple'
    end
  end

  class SecondSampleContext < TemplateContext
    def self.complex_merge_fields
      [{ name: :bar, context: ThirdSampleContext }]
    end

    def blah
      'blah'
    end
  end

  class ThirdSampleContext < TemplateContext
    def baz
      42
    end
  end

  describe '#merge_fields' do
    it 'expands subcontext merge fields' do
      expanded = [
        { name: :simple },
        { name: :foo, many: true, children: [
          { name: :blah },
          { name: :bar, children: [
            { name: :baz }
          ] }
        ] }
      ]
      mfb = MergeFieldBuilder.new(SampleContext)
      expect(mfb.merge_fields).to eq(expanded)
    end
  end
end
