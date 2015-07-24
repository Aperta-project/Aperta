require "rails_helper"

describe ClientRouteHelper do

  let(:paper) { double('paper', to_param: 1) }
  let(:task) { double('task', to_param: 1) }

  describe "#client_dashboard_url" do
    it "generates the url to the client paper's task" do
      url = client_dashboard_url
      expect(url).to eq("http://test.host/")
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

  describe "#client_edit_paper_url" do
    it "generates the url to the client paper's edit screen" do
      url = client_edit_paper_url(paper)
      expect(url).to eq("http://test.host/papers/1/edit")
    end
  end
end
