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

RSpec.shared_context "serialized json", serializer_test: true do
  let(:user) { nil }
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
