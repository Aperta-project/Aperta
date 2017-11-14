require 'rails_helper'

describe Behavior do
  let(:args) { { event_name: :fake_event } }
  let(:journal) { create(:journal) }

  class TestBehaviorAction < BehaviorAction
    def self.call(*args)
      super(*args)
    end
  end

  class TestBehavior < Behavior
    has_attributes boolean: %w[bool_attr], string: %w[string_attr], json: %w[json_attr]
    self.action_class = TestBehaviorAction
  end

  before(:each) do
    Event.register(:fake_event)
  end

  after(:each) do
    Event.deregister(:fake_name)
  end

  context 'when the action is send_email' do
    subject { build(:send_email_behavior, **args) }

    it 'should fail validation unless a letter_template is set' do
      expect(subject).not_to be_valid
    end
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

    it 'should not allow some random attr' do
      expect {
        subject.new(xxx_attr: true, **args)
      }.to raise_error(ActiveRecord::UnknownAttributeError)
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

  context 'with action' do
    let!(:behavior) do
      TestBehavior.create!(
        event_name: :fake_event,
        journal: journal,
        bool_attr: true,
        string_attr: 'foo',
        json_attr: { 'bar' => 'baz' }
      )
    end
    let(:paper) { FactoryGirl.create(:paper) }
    let(:user) { FactoryGirl.create(:user) }

    it 'should raise an exception if the class does not override call' do
      behavior
      expect { Event.trigger(:fake_event, paper: paper, user: user) }.to raise_error(NotImplementedError)
    end

    it 'should call the call method with both the action and behavior parameters' do
      behavior
      expect(TestBehaviorAction).to receive(:call).with(
        event_params: { user: user, paper: paper, task: nil },
        behavior_params: {
          "bool_attr" => true,
          "string_attr" => "foo",
          "json_attr" => { "bar" => "baz" }
        }
      )
      Event.trigger(:fake_event, paper: paper, user: user)
    end
  end
end
