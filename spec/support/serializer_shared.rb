RSpec.shared_context "serialized json", serializer_test: true do
  let(:serializer) { described_class.new(subject) }
  let(:serialized_content) { serializer.to_json }
  let(:deserialized_content) do
    JSON.parse(serialized_content, symbolize_names: true)
  end
end
