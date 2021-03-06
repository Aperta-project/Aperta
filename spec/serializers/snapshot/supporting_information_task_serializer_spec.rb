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

describe Snapshot::SupportingInformationTaskSerializer do
  subject(:serializer) { described_class.new(task) }
  let!(:paper) { FactoryGirl.create(:paper) }
  let!(:task) { FactoryGirl.create(:supporting_information_task, paper: paper) }
  let!(:si_file_1) do
    FactoryGirl.create(
      :supporting_information_file,
      :with_resource_token,
      caption: 'supporting info 1 caption',
      owner: task,
      paper: paper,
      title: 'supporting info 1 title',
    )
  end
  let!(:si_file_2) do
    FactoryGirl.create(
      :supporting_information_file,
      :with_resource_token,
      caption: 'supporting info 2 caption',
      owner: task,
      paper: paper,
      title: 'supporting info 2 title',
    )
  end

  describe '#as_json' do
    let(:si_files_json) do
      serializer.as_json[:children].select do |child_json|
        child_json[:name] == 'supporting-information-file'
      end
    end

    it 'serializes to JSON' do
      expect(serializer.as_json).to include(
        name: 'supporting-information-task',
        type: 'properties'
      )
    end

    it "serializes the supporting information files for the task's paper" do
      expect(si_files_json.length).to be 2

      expect(si_files_json[0]).to match hash_including(
        name: 'supporting-information-file',
        type: 'properties'
      )

      expect(si_files_json[0][:children]).to include(
        { name: 'id', type: 'integer', value: si_file_1.id },
        { name: 'file', type: 'text', value: si_file_1.filename },
        { name: 'file_hash', type: 'text', value: si_file_1.file_hash },
        { name: 'title', type: 'text', value: si_file_1.title },
        { name: 'caption', type: 'text', value: si_file_1.caption },
        { name: 'publishable', type: 'boolean', value: si_file_1.publishable },
        { name: 'url', type: 'url', value: si_file_1.non_expiring_proxy_url }
      )

      expect(si_files_json[1]).to match hash_including(
        name: 'supporting-information-file',
        type: 'properties'
      )
      expect(si_files_json[1][:children]).to include(
        { name: 'id', type: 'integer', value: si_file_2.id },
        { name: 'file', type: 'text', value: si_file_2.filename },
        { name: 'file_hash', type: 'text', value: si_file_2.file_hash },
        { name: 'title', type: 'text', value: si_file_2.title },
        { name: 'caption', type: 'text', value: si_file_2.caption },
        { name: 'publishable', type: 'boolean', value: si_file_2.publishable },
        { name: 'url', type: 'url', value: si_file_2.non_expiring_proxy_url }
      )
    end

    it_behaves_like 'snapshot serializes related answers as nested questions', resource: :task
  end
end
