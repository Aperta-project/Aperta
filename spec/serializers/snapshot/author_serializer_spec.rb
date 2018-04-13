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

describe Snapshot::AuthorSerializer do
  subject(:serializer) { described_class.new(author) }
  let(:author) do
    author = FactoryGirl.create(
      :author,
      first_name: "Reggie",
      last_name: "Watts",
      middle_initial: "U",
      email: "reggie@example.com",
      department: "Music",
      title: "Producer",
      affiliation: "Hip Hop",
      secondary_affiliation: "Another place",
      ringgold_id: "1234",
      secondary_ringgold_id: "9876"
    )
    author.position = 99
    author
  end

  describe "#as_json" do
    it "serializes to JSON" do
      expect(serializer.as_json).to include(
        name: "author",
        type: "properties"
      )
    end

    it "serializes the author's properties" do
      expect(serializer.as_json[:children]).to include(
        { name: "first_name", type: "text", value: "Reggie" },
        { name: "last_name", type: "text", value: "Watts" },
        { name: "middle_initial", type: "text", value: "U" },
        { name: "position", type: "integer", value: 99 },
        { name: "email", type: "text", value: "reggie@example.com" },
        { name: "department", type: "text", value: "Music" },
        { name: "title", type: "text", value: "Producer" },
        { name: "affiliation", type: "text", value: "Hip Hop" },
        { name: "secondary_affiliation", type: "text", value: "Another place" },
        { name: "ringgold_id", type: "text", value: "1234" },
        { name: "secondary_ringgold_id", type: "text", value: "9876" }
      )
    end

    it_behaves_like "snapshot serializes related answers as nested questions", resource: :author
  end
end
