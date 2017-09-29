require "rails_helper"

describe ClientRouteHelper do

  let(:paper) { double('paper', to_param: 1) }
  let(:task) { double('task', to_param: 1) }

  describe "#client_dashboard_url" do
    it "generates the url to the client paper's task" do
      url = client_dashboard_url
      expect(url).to eq("http://test.host/")
    end

    it "passes URL options thru" do
      url = client_dashboard_url(code: "123")
      expect(url).to eq("http://test.host/?code=123")
    end
  end

  describe "#client_paper_task_url" do
    it "generates the url to the client paper's task" do
      url = client_paper_task_url(paper, task)
      expect(url).to eq("http://test.host/papers/1/tasks/1")
    end
  end

  describe "#client_paper_url" do
    it "generates the url to the client paper" do
      url = client_paper_url(paper)
      expect(url).to eq("http://test.host/papers/1/")
    end

    pending "handle params"
  end

  describe '#client_voucher_invitiation_url' do
    let(:invitation) { double('task', token: 'hhf287gf278ogf87g4f4') }
    it 'generates the url to an invitation' do
      url = client_voucher_invitation_url(invitation)
      expect(url).to eq("http://test.host/voucher_invitations/hhf287gf278ogf87g4f4")
    end
  end
end
