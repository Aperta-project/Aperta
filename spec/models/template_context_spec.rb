require 'rails_helper'

describe TemplateContext do
  describe '.context' do
    context 'without options' do
      let(:paper) { Paper.new }
      let(:fake_model) { double("blah") }
      before do
        allow(fake_model).to receive(:paper).and_return(paper)

        ExampleContext = Class.new(TemplateContext) do
          context :paper
        end
      end

      it 'uses the argument to determine the method name and the context class to use' do
        example_context = ExampleContext.new(fake_model)
        expect(example_context.paper.class).to eq PaperContext
      end

      it 'uses the argument as the method to call to get the source object for the context' do
        example_context = ExampleContext.new(fake_model)
        expect(example_context.paper.send(:object)).to eq paper
      end
    end

    context 'with a :type option' do
      it 'uses the :type option to determine the context class' do
        fake_model = double("blah")
        allow(fake_model).to receive(:foo) { Paper.new }

        ExampleContext = Class.new(TemplateContext) do
          context :foo, type: :paper
        end

        expect(ExampleContext.new(fake_model).foo.class).to eq PaperContext
      end
    end

    context 'with a :source option' do
      it 'evaluates the :source option to get the object to pass to the context constructor' do
        fake_model = double("blah")
        allow(fake_model).to receive(:foo) { Paper.new(title: 'foobars in space') }

        ExampleContext = Class.new(TemplateContext) do
          context :paper, source: '@object.foo'
        end

        expect(ExampleContext.new(fake_model).paper.title).to eq 'foobars in space'
      end
    end

    context 'with a :many option' do
      it 'returns a collection of contexts' do
        fake_model = double("blah")
        allow(fake_model).to receive(:papers) { [Paper.new(title: 'first foobar')] }

        ExampleContext = Class.new(TemplateContext) do
          context :papers, type: :paper, many: true
        end

        expect(ExampleContext.new(fake_model).papers.map(&:class)).to eq [PaperContext]
        expect(ExampleContext.new(fake_model).papers.first.title).to eq 'first foobar'
      end
    end
  end

  describe '.contexts' do
    it 'delegates to .context, adding the option {many: true}' do
      expect(TemplateContext).to receive(:context).with(:bars, type: :author, many: true)
      TemplateContext.contexts(:bars, type: :author)
    end
  end
end
