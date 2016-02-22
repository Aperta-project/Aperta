require 'rails_helper'

RSpec.describe 'Permission Caching' do
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:role) { FactoryGirl.create(:role) }
  let(:auth_query) { double(Authorizations::Query) }
  let(:thing) { FactoryGirl.create(:paper) }
  let(:cache){ ActiveSupport::Cache::MemoryStore.new }

  before do
    allow(Rails).to receive(:cache).and_return(cache)
  end

  it 'should cache permissions' do
    expect(auth_query).to receive(:objects).and_return([true])

    expect(user).to receive(:filter_authorized).with(:foo, thing).once.and_return(auth_query)
    expect(user.can?(:foo, thing)).to be(true)

    # calling again should hit the cache
    expect(user).to_not receive(:filter_authorized)
    expect(user.can?(:foo, thing)).to be(true)
  end

  it "should clear the user's permissions cache if an assignment to that user is added" do
    expect(user.can?(:foo, thing)).to be(false)
    expect(Rails.cache).to receive(:clear).with(namespace: user.permissions_cache_namespace).and_call_original.at_least(:once)
    Assignment.create!(user: user, role: role, assigned_to: thing)
  end

  it "should not clear the user's permissions cache if an assignment to another user is added" do
    expect(user.can?(:foo, thing)).to be(false)
    expect(Rails.cache).not_to receive(:clear).with(namespace: user.permissions_cache_namespace)
    Assignment.create!(user: user2, role: role, assigned_to: thing)
  end

  it "should clear all user's permissions cache if a permission is added" do
    expect(user.can?(:foo, thing)).to be(false)
    expect(Rails.cache).to receive(:clear).with(namespace: user.permissions_cache_namespace).and_call_original.at_least(:once)
    expect(Rails.cache).to receive(:clear).with(namespace: user2.permissions_cache_namespace).and_call_original.at_least(:once)
    Role.ensure_exists(:foo) do |role|
      role.ensure_permission_exists(:view, applies_to: Paper)
    end
  end
end
