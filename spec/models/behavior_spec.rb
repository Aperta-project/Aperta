require 'rails_helper'

describe Behavior do
  let(:args) { { event_name: :fake_event } }
  let(:journal) { create(:journal) }

  class TestBehavior < Behavior
    has_attributes boolean: %w[bool_attr], string: %w[string_attr], json: %w[json_attr]
    def call(*args); end
  end

  before(:each) do
    Event.register(:fake_event)
  end

  after(:each) do
    Event.deregister(:fake_name)
  end

  describe TestBehavior do
    it_behaves_like :behavior_subclass
  end

  context 'event validation' do
    context 'when no subject is provided' do
      subject { TestBehavior.new }

      it 'should fail validation' do
        expect(subject).not_to be_valid
        expect(subject.errors[:event_name]).to include("can't be blank")
      end
    end

    context 'when the event_name is not registered' do
      subject { TestBehavior.new(event_name: :fake_event_2) }

      it 'should fail validation' do
        expect(subject).not_to be_valid
        expect(subject.errors[:event_name]).to include("is not included in the list")
      end
    end

    context 'when the event_name is registered' do
      subject(:behavior) { TestBehavior.new(event_name: :fake_event_2) }

      it 'should be valid' do
        Event.register(:fake_event_2)
        expect(subject).to be_valid
        Event.deregister(:fake_event_2)
      end
    end
  end

  context 'subclassing' do
    subject { TestBehavior }

    it 'should allow a bool_attr' do
      expect(subject.new(bool_attr: true, **args)).to be_valid
    end

    context 'with a validation' do
      subject do
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
