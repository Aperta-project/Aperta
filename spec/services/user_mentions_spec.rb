require 'rails_helper.rb'

describe UserMentions do
  let!(:user_a) { FactoryGirl.create(:user) }
  let!(:user_b) { FactoryGirl.create(:user) }
  let!(:poster) { FactoryGirl.create(:user) }
  let(:body) { "" }
  subject(:user_mentions) { UserMentions.new(body, poster) }

  describe '#all_users_mentioned' do
    subject(:all_users_mentioned) { user_mentions.all_users_mentioned }

    context 'body contains an at-mention' do
      let(:body) { "A mention of @#{user_a.username}" }

      it 'finds a user mention' do
        expect(all_users_mentioned.count).to eq(1)
        expect(all_users_mentioned).to include(user_a)
      end
    end

    context 'body contains an at-mention to the poster and another user' do
      let(:body) { "A mention of @#{user_a.username} by @#{poster.username}" }

      it 'does not include the poster' do
        expect(all_users_mentioned).to include(user_a)
        expect(all_users_mentioned).to_not include(poster)
      end
    end

    context 'body contains more than one at-mention' do
      let(:body) { "A mention of @#{user_a.username} and @#{user_b.username}" }

      it 'finds more than one mention' do
        expect(all_users_mentioned.count).to eq(2)
        expect(all_users_mentioned).to include(user_a)
        expect(all_users_mentioned).to include(user_b)
      end
    end

    context 'body contains at-mentions to users not in the user database' do
      let(:body) { 'A mention of @auserwhodoesnotexist' }

      it 'ignores usernames not in the user database' do
        expect(all_users_mentioned.count).to eq(0)
      end
    end

    context 'body contains a username with mixed case' do
      let(:user_a) { create :user, username: 'TestUserCase' }
      let(:body) { "A mention of @#{user_a.username}" }

      it 'matches when username is mixed case' do
        expect(all_users_mentioned.count).to eq(1)
        expect(all_users_mentioned).to include(user_a)
      end
    end
  end

  describe '#decorated_mentions' do
    subject(:decorated_mentions) { user_mentions.decorated_mentions }
    let(:body) { "@#{user_a.username}" }

    it 'returns the body with decorated at-mentions' do
      expected_html = parse_html <<-HTML.gsub!(/\s+/, " ").strip
       <a class="discussion-at-mention"
          data-user-id="#{user_a.id}"
          title="#{user_a.full_name}">@#{user_a.username}</a>
      HTML
      expect(parse_html(decorated_mentions)).to be_equivalent_to expected_html
    end
  end

  describe '#notifiable_users_mentioned' do
    let(:permission_object) { double }
    let(:user_mentions) { UserMentions.new(body, poster, permission_object: permission_object) }
    subject(:notifiable_users_mentioned) { user_mentions.notifiable_users_mentioned }

    context 'with a user that can not be_at_mentioned' do
      before do
        expect(user_a).to receive(:can?).with(:be_at_mentioned, permission_object).and_return(false)
        expect(user_mentions).to receive(:all_users_mentioned).and_return([user_a])
      end

      it 'should not return that user' do
        is_expected.to be_empty
      end
    end

    context 'with a user that can be_at_mentioned' do
      before do
        expect(user_a).to receive(:can?).with(:be_at_mentioned, permission_object).and_return(true)
        expect(user_mentions).to receive(:all_users_mentioned).and_return([user_a])
      end

      it 'should return that user' do
        is_expected.to eq [user_a]
      end
    end

    context 'two users--one who can and one who cant be_at_mentioned' do
      before do
        expect(user_a).to receive(:can?).with(:be_at_mentioned, permission_object).and_return(false)
        expect(user_b).to receive(:can?).with(:be_at_mentioned, permission_object).and_return(true)
        expect(user_mentions).to receive(:all_users_mentioned).and_return([user_a, user_b])
      end

      it 'should return the single user that can be_at_mentioned' do
        is_expected.to eq [user_b]
      end
    end
  end
end
