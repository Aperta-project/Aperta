require 'rails_helper'

class TestAuthzSerializer < AuthzSerializer
  attributes :foo
  has_one :viewable, include: true, serializer: 'TestAuthzSerializerLeaf'
  has_one :unviewable, include: true, serializer: 'TestAuthzSerializerLeaf'
end

class TestAuthzSerializerLeaf < AuthzSerializer
  attributes :foo
end

class TestAuthzObject
  include ActiveModel::SerializerSupport

  def foo
    'foo'
  end

  def viewable
    # override
  end

  def unviewable
    # override
  end

  def user_can_view?(_user)
    # override
  end

  def id
    # override
  end
end

describe AuthzSerializer do
  let(:user) { FactoryGirl.create(:user) }
  let(:foo) { { foo: 'foo' } }
  let(:serializer) { TestAuthzSerializer.new(root_object, scope: scope) }
  let(:json) { serializer.as_json }
  let(:root_object) { TestAuthzObject.new }
  let(:other_root_object) { TestAuthzObject.new }
  let(:viewable_object) { TestAuthzObject.new }
  let(:unviewable_object) { TestAuthzObject.new }
  let(:array) { [root_object, other_root_object] }

  before do
    expect(root_object).to receive(:viewable).and_return(viewable_object)
    expect(root_object).to receive(:unviewable).and_return(unviewable_object)
    allow(root_object).to receive(:id).and_return(1)
    allow(viewable_object).to receive(:id).and_return(2)
    allow(unviewable_object).to receive(:id).and_return(3)
  end

  context 'when the scope is the current user' do
    let(:scope) { user }

    before do
      expect(viewable_object).to receive(:user_can_view?).with(user).and_return(true).at_least(:once)
      expect(unviewable_object).to receive(:user_can_view?).with(user).and_return(false).at_least(:once)

      # We expect this method *not* to be called at the root, because the root
      # object should *not* check authz
      allow(root_object).to receive(:user_can_view?).and_raise(Exception)
    end

    it 'should include the attributes at the top level' do
      expect(json[:test_authz]).to match(hash_including(foo: 'foo'))
    end

    it 'should include the attributes of the viewable object' do
      expect(json[:test_authz][:viewable]).to eq(foo)
    end

    it 'should not include the attributes of the unviewable object' do
      expect(json[:test_authz][:unviewable]).to eq(id: 3)
    end

    describe 'when using array serializer' do
      before do
        expect(other_root_object).to receive(:viewable).and_return(viewable_object)
        expect(other_root_object).to receive(:unviewable).and_return(unviewable_object)

        # We expect this method *not* to be called at the root, because the root
        # object should *not* check authz
        allow(other_root_object).to receive(:user_can_view?).and_raise(Exception)
      end

      it 'should serialize both objects and call user_can_view? on the second object' do
        json = ActiveModel::ArraySerializer.new(array, scope: user, each_serializer: TestAuthzSerializer).as_json
        expect(json).to contain_exactly(foo.merge(viewable: foo, unviewable: { id: 3 }), foo.merge(viewable: foo, unviewable: { id: 3 }))
      end
    end
  end

  context 'when scope is nil' do
    let(:scope) { nil }

    it 'should always return true' do
      expect(json[:test_authz]).to match(hash_including(foo: 'foo'))
      expect(json[:test_authz][:viewable]).to eq(foo)
      expect(json[:test_authz][:unviewable]).to eq(foo)
    end
  end
end
