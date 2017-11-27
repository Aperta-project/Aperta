require 'rails_helper'

describe TemplateContext do
  describe '.context' do
    let(:fake_model) { double("blah") }
    let(:context_class) { Class.new(TemplateContext) }
    let(:context_instance) { context_class.new(fake_model) }

    context 'without options' do
      before do
        context_class.send(:subcontext, :paper)
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
        context_class.send(:subcontext, :foo, type: :paper)

        expect(context_instance.foo.class).to eq PaperContext
      end
    end

    context 'with a :source option' do
      it 'evaluates the :source option as a method call chain to get the object to pass to the context constructor' do
        allow(fake_model).to receive(:foo) { Paper.new(title: 'foobars in space') }
        context_class.send(:subcontext, :paper, source: [:object, :foo])

        expect(context_instance.paper.title).to eq 'foobars in space'
      end
    end

    context 'with a :is_array option' do
      it 'returns a collection of contexts' do
        allow(fake_model).to receive(:papers) { [Paper.new(title: 'first foobar')] }
        context_class.send(:subcontext, :papers, type: :paper, is_array: true)

        expect(context_instance.papers.map(&:class)).to eq [PaperContext]
        expect(context_instance.papers.first.title).to eq 'first foobar'
      end
    end
  end

  describe '.contexts' do
    it 'delegates to .context, adding the option {is_array: true}' do
      expect(TemplateContext).to receive(:subcontext).with(:bars, type: :author, is_array: true)
      TemplateContext.subcontexts(:bars, type: :author)
    end
  end

  describe '.wraps' do
    context 'specifies a wrapped type' do
      it 'returns the wrapped type' do
        expect(PaperScenario.wraps).to eq Paper
      end

      it 'raises when constructor is passed an instance of the wrong type' do
        expect { PaperScenario.new(Task.new) }.to raise_error "PaperScenario expected to wrap a Paper but got a Task"
      end

      it 'does not raise when constructor is passed an instance of the right type' do
        expect { PaperScenario.new(Paper.new) }.to_not raise_error
      end
    end

    context 'does not specify a wrapped type' do
      it 'returns nil' do
        expect(AuthorContext.wraps).to be_nil
      end

      it 'does not raise when the constructor is passed an unexpected type' do
        expect { AuthorContext.new(Paper.new) }.to_not raise_error
      end
    end
  end
end
