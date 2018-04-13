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

require 'rails_helper'

describe Jira do
  subject { described_class }

  describe '#build_payload' do
    let(:user) { FactoryGirl.create(:user, first_name: 'Barbara', last_name: 'Foo') }
    let(:params) { { remarks: 'talks' } }
    it 'should return a properly formatted hash' do
      fields = subject.build_payload(user, params)[:fields]
      expect(fields[:summary]).to include(user.full_name)
      expect(fields[:description]).to include('talks')
    end

    it 'adds custom jira issue fields' do
      paper = FactoryGirl.create(:paper)
      params.merge!(
        browser: 'Firefox 42.3',
        platform: 'Platform 9',
        paper_id: paper.id
      )

      fields = subject.build_payload(user, params)[:fields]
      expect(fields[:customfield_13439]).to eq([{ value: 'CircleCI' }])
      expect(fields[:customfield_13500]).to eq(user.username)
      expect(fields[:customfield_13501]).to eq('Firefox 42.3')
      expect(fields[:customfield_13502]).to eq('Platform 9')
      expect(fields[:customfield_13503]).to eq(paper.doi)
    end

    context 'with one attachment' do
      let(:params) do
        {
          remarks: 'talks',
          screenshots: [
            { url: 'http://example.com/file?name=awesomeness.gif', name: 'Awesomeness' }
          ]
        }
      end
      it 'should attach a link to the attachment' do
        payload = subject.build_payload(user, params)
        expect(payload.dig(:fields, :description)).to match(/awesomeness\.gif/)
      end
    end

    context 'with multiple attachments' do
      let(:params_with_multiple_attachments) do
        {
          remarks: 'talks',
          screenshots: [
            { url: 'http://example.com/file?name=awesomeness.gif', name: 'Awesomeness' },
            { url: 'http://example.com/file?name=ssenemosewa.gif', name: 'ssenemosewA' }
          ]
        }
      end

      it 'should attach the links to the attachments' do
        payload = subject.build_payload(user, params_with_multiple_attachments)
        expect(payload.dig(:fields, :description)).to match(/awesomeness\.gif/)
        expect(payload.dig(:fields, :description)).to match(/ssenemosewa\.gif/)
      end
    end
  end
end
