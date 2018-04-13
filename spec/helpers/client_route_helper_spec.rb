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

  describe '#client_show_invitation_url' do
    let(:invitation) { double('task', token: 'hhf287gf278ogf87g4f4') }
    it 'generates the url to an invitation' do
      url = client_show_invitation_url(token: invitation.token)
      expect(url).to eq("http://test.host/invitations/#{invitation.token}")
    end
  end

  describe "#client_show_correspondence_url" do
    let(:correspondence) { create :correspondence }
    it "generates the url to a correspondence" do
      url = client_show_correspondence_url(correspondence)
      expect(url).to include "/#{correspondence.paper.short_doi}/correspondence/viewcorrespondence/#{correspondence.id}"
    end
  end

  describe '#client_coauthor_url' do
    let(:coauthor) { double(token: 'foo') }
    it 'generates the url to a coauthor confirmation page' do
      url = client_coauthor_url(token: coauthor.token)
      expect(url).to eq("http://test.host/co_authors_token/#{coauthor.token}")
    end
  end
end
