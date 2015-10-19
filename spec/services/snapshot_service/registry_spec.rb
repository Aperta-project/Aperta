require "rails_helper"

describe SnapshotService::Registry do
  class ExampleSerializer ; end
  class Thing ; end
  class SubclassOfThing < Thing ; end

  subject(:registry) { described_class.new }

  describe "registering serializers" do
    let(:object) { Thing.new }

    before { registry.serialize(Thing, with: ExampleSerializer) }

    it "returns the serializer registered for the given object" do
      expect(registry.serializer_for(object)).to eq(ExampleSerializer)
    end

    context "determining the serializer for the given object" do
      it "returns the serializer for the given class if one is registered" do
        expect(registry.serializer_for(object)).to eq(ExampleSerializer)
      end

      it "falls back to returning a serializer for an ancestor class if one is registered" do
        expect(registry.serializer_for(SubclassOfThing.new)).to eq(ExampleSerializer)
      end
    end

    context "when a duplicate serializer is being registered" do
      it "raises an DuplicateRegistrationError" do
        expect do
          registry.serialize(Thing, with: ExampleSerializer)
        end.to raise_error(SnapshotService::Registry::DuplicateRegistrationError)
      end
    end

    context "when no serializer is registered for the given object" do
      before { registry.clear }

      it "raises a NoSerializerRegisteredError" do
        expect do
          registry.serializer_for(object)
        end.to raise_error(SnapshotService::Registry::NoSerializerRegisteredError)
      end
    end
  end
end
