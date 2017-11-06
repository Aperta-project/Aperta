require 'rails_helper'

describe TemplateContext do
  describe '.context' do
    let(:fake_model) { double("blah") }
    let(:context_class) { Class.new(TemplateContext) }
    let(:context_instance) { context_class.new(fake_model) }

    context 'without options' do
      before do
        context_class.send(:context, :paper)
      end

      it 'uses the argument to determine the method name and the context class to use' do
        allow(fake_model).to receive(:paper).and_return(Paper.new)

        expect(context_instance.paper.class).to eq PaperContext
      end

      it 'uses the argument as the method to call to get the source object for the context' do
        paper = Paper.new
        allow(fake_model).to receive(:paper).and_return(paper)

        expect(context_instance.paper.send(:object)).to eq paper
      end
    end

    context 'with a :type option' do
      it 'uses the :type option to determine the context class' do
        allow(fake_model).to receive(:foo) { Paper.new }
        context_class.send(:context, :foo, type: :paper)

        expect(context_instance.foo.class).to eq PaperContext
      end
    end

    context 'with a :source option' do
      it 'evaluates the :source option as a method call chain to get the object to pass to the context constructor' do
        allow(fake_model).to receive(:foo) { Paper.new(title: 'foobars in space') }
        context_class.send(:context, :paper, source: [:object, :foo])

        expect(context_instance.paper.title).to eq 'foobars in space'
      end
    end

    context 'with a :many option' do
      it 'returns a collection of contexts' do
        allow(fake_model).to receive(:papers) { [Paper.new(title: 'first foobar')] }
        context_class.send(:context, :papers, type: :paper, many: true)

        expect(context_instance.papers.map(&:class)).to eq [PaperContext]
        expect(context_instance.papers.first.title).to eq 'first foobar'
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
