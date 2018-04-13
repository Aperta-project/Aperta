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

describe Snapshot::BaseSerializer do
  class Snapshot::TestSerializer < Snapshot::BaseSerializer
    private

    def snapshot_properties
      [{ properties: "here" }]
    end

    def snapshot_card_content
      [{ questions: "here" }]
    end
  end

  describe "snapshot ordering of children" do
    subject(:serializer) { Snapshot::TestSerializer.new(model) }
    let(:model) { OpenStruct.new(card_content: [], id: 1) }

    it "snapshots card_content first, then id, then other properties" do
      expect(serializer.as_json[:children]).to eq([
        { questions: "here" },
        { name: "id", type: "integer", value: 1 },
        { properties: "here" }
      ])
    end
  end

  context "with multiple versions" do
    subject(:serializer) { Snapshot::BaseSerializer.new(model) }

    # task with card that has two different card versions,
    # one that is published, one that is draft
    let(:card) { FactoryGirl.create(:card, :published_with_changes) }
    let(:published_card_version) { card.card_versions.published.first }
    let(:unpublished_card_version) { card.card_versions.unpublished.first }
    let!(:unpublished_child) { FactoryGirl.create(:card_content, card_version: unpublished_card_version, parent: unpublished_card_version.content_root) }
    let!(:published_child) { FactoryGirl.create(:card_content, card_version: published_card_version, parent: published_card_version.content_root) }

    # custom card task where the card version it is using is the published one
    let(:model) { FactoryGirl.create(:custom_card_task, card_version: published_card_version) }

    it "snapshots only the latest published version" do
      aggregate_failures do
        expect(serializer.as_json[:children].length).to eq(2)
        expect(serializer.as_json[:children][0][:name]).to eq(published_child.ident)
        expect(serializer.as_json[:children][1][:name]).to eq("id")
      end
    end
  end
end
