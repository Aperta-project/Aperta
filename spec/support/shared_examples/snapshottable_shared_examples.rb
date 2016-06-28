RSpec.shared_examples_for 'is not snapshottable' do
  describe '.snapshottable' do
    it 'is not snapshottable' do
      expect(described_class.snapshottable).to be(false)
    end
  end

  describe '#snapshottable' do
    it 'is not snapshottable' do
      expect(described_class.new.snapshottable).to be(false)
    end
  end
end

RSpec.shared_examples_for 'is snapshottable' do
  describe '.snapshottable' do
    it 'is snapshottable' do
      expect(described_class.snapshottable).to be(true)
    end
  end

  describe '#snapshottable' do
    it 'is snapshottable' do
      expect(described_class.new.snapshottable).to be(true)
    end
  end
end
