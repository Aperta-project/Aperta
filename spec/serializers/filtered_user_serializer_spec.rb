require 'rails_helper'

describe FilteredUserSerializer do
  let(:user) { create :user }

  it "serializes a few user attributes" do
    data = FilteredUserSerializer.new(user).as_json

    expect(data[:filtered_user].keys).to contain_exactly(:id, :full_name, :username, :avatar_url)
  end
end
