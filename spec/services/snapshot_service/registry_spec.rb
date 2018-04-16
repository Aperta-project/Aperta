# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require "rails_helper"

describe SnapshotService::Registry do
  class ExampleSerializer ; end
  class Thing ; end
  class SubclassOfThing < Thing ; end

  subject(:registry) { described_class.new }

  describe "#empty?" do
    context "and there are no registrations" do
      it "returns true" do
        expect(registry.empty?).to be(true)
      end
    end

    context "and there are registrations" do
      before { registry.serialize(Thing, with: ExampleSerializer) }

      it "returns false" do
        expect(registry.empty?).to be(false)
      end
    end
  end

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
