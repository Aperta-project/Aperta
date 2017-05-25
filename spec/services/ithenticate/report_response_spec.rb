describe Ithenticate::ReportResponse do
  let(:view_only_url) { "https://api.ithenticate.com/view_report/C3DAB7BC-2D1D-11E7-BC75-ED764A89A445" }
  let(:report_url) { "https://api.ithenticate.com/report/28501019/similarity" }
  let(:response_hash) do
    {
      "api_status" => 200,
      "report_url" => report_url,
      "sid" => "1fa29a7a375b12272f2aab86ce663726881a37ab",
      "status" => 200,
      "view_only_url" => view_only_url
    }
  end
  subject(:response) { Ithenticate::ReportResponse.new(response_hash) }

  describe ".new" do
    it "returns an instance of Ithenticate::ReportResponse" do
      expect(response).to be_an_instance_of(Ithenticate::ReportResponse)
    end
  end

  describe "#view_only_url" do
    subject { response.view_only_url }

    it { is_expected.to eq view_only_url }
  end

  describe "#report_url" do
    subject { response.report_url }

    it { is_expected.to eq report_url }
  end
end
