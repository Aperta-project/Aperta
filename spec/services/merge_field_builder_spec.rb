require 'rails_helper'

describe MergeFieldBuilder do
  class SampleContext < TemplateContext
    contexts :foo, type: :second_sample
    def simple
      'so simple'
    end
  end

  class SecondSampleContext < TemplateContext
    context :bar, type: :third_sample
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
      merge_fields = MergeFieldBuilder.merge_fields(SampleContext)
      expect(merge_fields).to eq(expanded)
    end
  end
end
