describe Ithenticate::Api do
  describe ".new_from_tahi_env" do
    subject(:api) { Ithenticate::Api.new_from_tahi_env }

    it "returns an instance of Ithenticate::Api" do
      expect(api).to be_an_instance_of(Ithenticate::Api)
    end
  end
end
