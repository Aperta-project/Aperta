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

describe Ithenticate::DocumentResponse do
  let(:report_id) { 28_501_019 }
  let(:score) { 97 }

  let(:response_hash) do
    {
      "api_status" => 200,
      "documents" => [
        {
          "author_first" => "ninja",
          "author_last" => "turtle",
          "id" => 28_916_221,
          "is_pending" => 0,
          "parts" => [
            {
              "doc_id" => 28_916_221,
              "id" => report_id,
              "max_percent_match" => 95,
              "score" => score,
              "words" => 5_417
            }
          ]
        }
      ]
    }
  end

  subject(:response) { Ithenticate::DocumentResponse.new(response_hash) }

  describe ".new" do
    it "returns an instance of Ithenticate::Response" do
      expect(response).to be_an_instance_of(Ithenticate::DocumentResponse)
    end
  end

  context "the report is finished" do
    describe "#report_id" do
      subject { response.report_id }

      it { is_expected.to eq report_id }
    end

    describe "#report_complete" do
      subject { response.report_complete? }

      it { is_expected.to eq true }
    end

    describe "#score" do
      subject { response.score }

      it { is_expected.to eq score }
    end
  end
end
