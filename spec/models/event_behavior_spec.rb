require 'rails_helper'

describe EventBehavior do
  let(:args) { { event_name: :fake_event } }
  before(:each) do
    Event.register(:fake_event)
  end

  after(:each) do
    Event.clear_registry
  end

  context 'when the action is send_email' do
    subject(:event_behavior) { build(:send_email_behavior, **args) }

    it 'should fail validation unless a letter_template is set' do
      expect(subject).not_to be_valid
    end
  end

  context 'event validation' do
    let(:klass) do
      Class.new(described_class) do
        def self.name
          'TestBehavior'
        end
        has_attributes boolean: %w[bool_attr]
      end
    end

    context 'when no subject is provided' do
      subject(:behavior) { klass.new }

      it 'should fail validation' do
        expect(subject).not_to be_valid
        expect(subject.errors[:event_name]).to include("can't be blank")
      end
    end

    context 'when the event_name is not registered' do
      subject(:behavior) { klass.new(event_name: :fake_event_2) }

      it 'should fail validation' do
        expect(subject).not_to be_valid
        expect(subject.errors[:event_name]).to include("is not included in the list")
      end
    end

    context 'when the event_name is registered' do
      subject(:behavior) { klass.new(event_name: :fake_event_2) }

      it 'should be valid' do
        Event.register(:fake_event_2)
        expect(subject).to be_valid
        Event.clear_registry
      end
    end
  end

  context 'subclassing' do
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
