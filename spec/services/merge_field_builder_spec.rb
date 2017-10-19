require 'rails_helper'

describe MergeFieldBuilder do
  class SampleContext < TemplateContext
    def simple
      'so simple'
    end
  end

  class SecondSampleContext < TemplateContext
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
    before do
      sample_definitions = Hash.new { [] }
      sample_definitions[SampleContext] = [{ name: :foo, context: SecondSampleContext, many: true }]
      sample_definitions[SecondSampleContext] = [{ name: :bar, context: ThirdSampleContext }]
      MergeFieldBuilder.instance_variable_set(:@complex_merge_fields, sample_definitions)
    end

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
