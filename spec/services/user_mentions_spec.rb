require 'rails_helper.rb'

describe UserMentions do
  let!(:user_a) { FactoryGirl.create(:user) }
  let!(:user_b) { FactoryGirl.create(:user) }
  let!(:poster) { FactoryGirl.create(:user) }

  it 'finds a user mention' do
    body = "A mention of @#{user_a.username}"
    people_mentioned = UserMentions.new(body, poster).people_mentioned

    expect(people_mentioned.count).to eq(1)
    expect(people_mentioned).to include(user_a)
  end

  it 'does not include the poster' do
    body = "A mention of @#{user_a.username} by @#{poster.username}"
    people_mentioned = UserMentions.new(body, poster).people_mentioned

    expect(people_mentioned).to include(user_a)
    expect(people_mentioned).to_not include(poster)
  end

  it 'finds more than one mention' do
    body = "A mention of @#{user_a.username} and @#{user_b.username}"
    people_mentioned = UserMentions.new(body, poster).people_mentioned

    expect(people_mentioned.count).to eq(2)
    expect(people_mentioned).to include(user_a)
    expect(people_mentioned).to include(user_b)
  end

  it 'ignores usernames not in the user database' do
    body = 'A mention of @auserwhodoesnotexist'
    people_mentioned = UserMentions.new(body, poster).people_mentioned

    expect(people_mentioned.count).to eq(0)
  end

  it 'matches when username is mixed case' do
    user_a.update_attributes username: 'TestUserCase'
    body = "A mention of @#{user_a.username}"
    people_mentioned = UserMentions.new(body, poster).people_mentioned

    expect(people_mentioned.count).to eq(1)
    expect(people_mentioned).to include(user_a)
  end
end
