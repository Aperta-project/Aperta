RSpec.shared_context "serialized json", serializer_test: true do
  let(:options_for_serializer) { Hash.new }
  let(:object_for_serializer) { fail ArgumentError, 'Please set the object_for_serializer let binding!' }
  let(:serializer) { described_class.new(object_for_serializer, options_for_serializer) }
  let(:serialized_content) { serializer.to_json }
  let(:deserialized_content) do
    JSON.parse(serialized_content, symbolize_names: true)
  end
end
