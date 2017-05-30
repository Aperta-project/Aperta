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
