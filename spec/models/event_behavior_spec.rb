require 'rails_helper'

describe EventBehavior do
  let(:args) { { event_name: :paper_submitted } }

  context 'when the action is send_email' do
    subject(:event_behavior) { build(:send_email_behavior) }

    it 'should fail validation unless a letter_template is set' do
      expect(subject).not_to be_valid
    end
  end

  context 'subclassing ' do
    subject(:klass) do
      Class.new(described_class) do
        def self.name
          'TestBehavior'
        end
        has_attributes boolean: %w[bool_attr]
      end
    end

    it 'should allow a bool_attr' do
      expect(subject.new(bool_attr: true, **args)).to be_valid
    end

    it 'should not allow some random attr' do
      expect {
        subject.new(xxx_attr: true, **args)
      }.to raise_error(ActiveRecord::UnknownAttributeError)
    end

    context 'with a validation' do
      subject(:klass) do
        Class.new(described_class) do
          def self.name
            'TestBehavior'
          end
          has_attributes string: %w[string_attr]
          validates :string_attr, inclusion: { in: %w[foo bar] }
        end
      end

      it 'should validate string_attr' do
        expect(subject.new(string_attr: 'baz', **args)).not_to be_valid
        expect(subject.new(string_attr: 'bar', **args)).to be_valid
      end
    end
  end
end
