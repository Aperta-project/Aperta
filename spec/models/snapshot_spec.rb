require 'rails_helper'

describe Snapshot, type: :model do
  subject(:snapshot) { FactoryGirl.build(:snapshot) }

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
      FactoryGirl.create(:ad_hoc_task).tap do |task|
        def task.snapshot_key
          'abc123'
        end
      end
    end
    let(:source_without_snapshot_key) do
      FactoryGirl.create(:ad_hoc_task).tap do |task|
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

  describe "#get_property" do
    context "the requested property exists" do
      let(:key_name) { "my_key_name" }
      let(:key_value) { "my_key_value" }
      let(:snapshot) do
        create(:snapshot).tap do |snap|
          contents = {
            "children": [
              {
                "name" => key_name,
                "value" => key_value
              }
            ]
          }
          snap.update! contents: contents
        end
      end

      subject { snapshot.get_property(key_name) }

      it "returns the value of that property" do
        expect(subject).to eq key_value
      end
    end

    context "the requested property does not exist" do
      let(:key_name) { "my_key_name" }
      let(:key_value) { "my_key_value" }
      let(:snapshot) do
        create(:snapshot).tap do |snap|
          contents = {
            "children": []
          }
          snap.update! contents: contents
        end
      end

      subject { snapshot.get_property(key_name) }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end
end
