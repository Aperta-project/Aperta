describe Ithenticate::Response do
  let(:response_hash) do
    {
      "api_status" => 200,
      "report_url" => "https://api.ithenticate.com/report/28501019/similarity",
      "sid" => "1fa29a7a375b12272f2aab86ce663726881a37ab",
      "status" => 200,
      "view_only_url" => "https://api.ithenticate.com/view_report/C3DAB7BC-2D1D-11E7-BC75-ED764A89A445"
    }
  end
  subject(:response) { Ithenticate::Response.new(response_hash) }

  describe ".new" do
    it "returns an instance of Ithenticate::Response" do
      expect(response).to be_an_instance_of(Ithenticate::Response)
    end
  end
end
