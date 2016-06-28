RSpec.shared_examples_for 'is a metadata task' do
  describe 'as a metadata task' do
    include_examples 'is snapshottable'

    it 'adds itself to Task.metadata_types' do
      expect(Task.metadata_types).to include(described_class.name)
    end
  end
end
