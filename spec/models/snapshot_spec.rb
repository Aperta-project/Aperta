require 'rails_helper'

describe Snapshot, type: :model do
  subject(:snapshot){ FactoryGirl.build(:snapshot) }

  describe "validations" do
    it "is valid" do
      expect(snapshot.valid?).to be(true)
    end

    it "requires a :paper" do
      snapshot.paper = nil
      expect(snapshot.valid?).to be(false)
    end

    it "requires a :source" do
      snapshot.source = nil
      expect(snapshot.valid?).to be(false)
    end

    it "requires a :major_version" do
      snapshot.major_version = nil
      expect(snapshot.valid?).to be(false)
    end

    it "requires a :minor_version" do
      snapshot.minor_version = nil
      expect(snapshot.valid?).to be(false)
    end
  end

  describe 'setting #key' do
    let(:snapshot) { FactoryGirl.build(:snapshot) }
    let(:source_with_snapshot_key) do
      FactoryGirl.create(:task).tap do |task|
        def task.snapshot_key
          'abc123'
        end
      end
    end
    let(:source_without_snapshot_key) do
      FactoryGirl.create(:task).tap do |task|
        class << task
          undef_method :snapshot_key
        end
      end
    end

    before do
      expect(source_with_snapshot_key.snapshot_key).to eq('abc123')
      expect(source_without_snapshot_key.respond_to?(:snapshot_key)).to be false
    end

    it 'is set when assigning #source and the source has a snapshot_key' do
      expect do
        snapshot.source = source_with_snapshot_key
      end.to change { snapshot.key }.to eq source_with_snapshot_key.snapshot_key
    end

    it 'is not set when assigning #source does not respond to snapshot_key' do
      expect do
        snapshot.source = source_without_snapshot_key
      end.to_not change { snapshot.key }
    end
  end

end
