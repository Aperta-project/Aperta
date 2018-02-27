RSpec.shared_context "serialized json", serializer_test: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:options_for_serializer) { Hash.new }
  let(:object_for_serializer) { raise ArgumentError, 'Please set the object_for_serializer let binding!' }
  let(:serializer) { described_class.new(object_for_serializer, options_for_serializer.merge(scope: user)) }
  let(:serialized_content) { serializer.to_json }
  let(:deserialized_content) do
    JSON.parse(serialized_content, symbolize_names: true)
  end

  shared_examples_for :standard_no_view_access do
    context "when the user has no access" do
      before do
        expect(object_for_serializer).to receive(:user_can_view?).with(user).and_return(false).at_least(:once)
      end

      it "should only return the id" do
        expect(deserialized_content[object_for_serializer.class.name.underscore.to_sym]).to eq(id: object_for_serializer.id)
      end
    end
  end
end
