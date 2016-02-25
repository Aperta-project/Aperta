require 'rails_helper'

RSpec.describe 'Permission Caching' do
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:role) { FactoryGirl.create(:role) }
  let(:auth_query) { double(Authorizations::Query) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:task) { FactoryGirl.create(:task, paper: paper) }
  let(:discussion_topic) { FactoryGirl.create(:discussion_topic, paper: paper) }
  let(:cache) { ActiveSupport::Cache::MemoryStore.new }

  before do
    allow(Rails).to receive(:cache).and_return(cache)
  end

  matcher :hit_the_cache_for do |u, permission, thing|
    match do |block|
      RSpec::Mocks.space.proxy_for(u).reset
      allow(u).to receive(:can_uncached?).with(permission, thing).and_return(true)
      block.call
      expect(u).not_to have_received(:can_uncached?).with(permission, thing)
      true
    end

    match_when_negated do |actual|
      RSpec::Mocks.space.proxy_for(u).reset
      allow(u).to receive(:can_uncached?).with(permission, thing).and_return(true)
      actual.call
      expect(u).to have_received(:can_uncached?).with(permission, thing).once
      true
    end

    supports_block_expectations
  end

  it 'should cache permissions' do
    expect { user.can?(:foo, paper) }.not_to hit_the_cache_for(user, :foo, paper)
    expect { user.can?(:foo, paper) }.to hit_the_cache_for(user, :foo, paper)
  end

  it "should clear the user's permissions cache if an assignment to that user is added" do
    expect { user.can?(:foo, paper) }.not_to hit_the_cache_for(user, :foo, paper)

    Assignment.create!(user: user, role: role, assigned_to: paper)

    expect { user.can?(:foo, paper) }.not_to hit_the_cache_for(user, :foo, paper)
  end

  it "should not clear the user's permissions cache if an assignment to another user is added" do
    expect { user.can?(:foo, paper) }.not_to hit_the_cache_for(user, :foo, paper)
    expect { user2.can?(:foo, paper) }.not_to hit_the_cache_for(user2, :foo, paper)

    Assignment.create!(user: user2, role: role, assigned_to: paper)

    expect { user.can?(:foo, paper) }.to hit_the_cache_for(user, :foo, paper)
    expect { user2.can?(:foo, paper) }.not_to hit_the_cache_for(user2, :foo, paper)
  end

  [:task, :discussion_topic, :paper].each do |target_name|
    it "should expire the permssion cache for a #{target_name} if a paper changes state" do
      target = send(target_name)
      expect { user.can?(:foo, target) }.not_to hit_the_cache_for(user, :foo, target)

      paper.submit!(user)

      expect { user.can?(:foo, target) }.not_to hit_the_cache_for(user, :foo, target)
    end
  end

  it "should expire all user's permission caches if a permission is added" do
    expect { user.can?(:foo, paper) }.not_to hit_the_cache_for(user, :foo, paper)
    expect { user2.can?(:foo, paper) }.not_to hit_the_cache_for(user2, :foo, paper)

    Role.ensure_exists(:foo) do |role|
      role.ensure_permission_exists(:view, applies_to: Paper)
    end

    expect { user.can?(:foo, paper) }.not_to hit_the_cache_for(user, :foo, paper)
    expect { user2.can?(:foo, paper) }.not_to hit_the_cache_for(user2, :foo, paper)
  end
end
