require "rails_helper"

describe TahiStandardTasks::RelatedArticlesTaskSerializer,
         serializer_test: true do
  let(:object_for_serializer) { FactoryGirl.create :related_articles_task }
  let(:user) { FactoryGirl.build_stubbed(:user) }
  let(:serializer) {
    TahiStandardTasks::RelatedArticlesTaskSerializer.new(object_for_serializer,
                                                         scope: user)
  }

  before do
    allow(user).to receive(:can?)
      .with(:view, object_for_serializer)
      .and_return true
  end

  it "serializes successfully" do
    expect(deserialized_content).to be_kind_of Hash
  end

  describe "serialized content" do
    it 'includes the data we expect' do
      expect(deserialized_content)
        .to match(hash_including({}))
    end
  end
end
