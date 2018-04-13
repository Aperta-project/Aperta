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

module TahiStandardTasks
  describe SupportingInformationTask do
    it_behaves_like 'is a metadata task'

    describe '.restore_defaults' do
      it_behaves_like '<Task class>.restore_defaults update title to the default'
    end

    describe "#file_access_details" do
      before :each do
        files = [double(:file, access_details: :hello)]
        paper = double(:paper, files: files)
        allow(supporting_information_task).to receive(:paper).and_return(paper)
      end

      let(:supporting_information_task) { FactoryGirl.create(:supporting_information_task) }

      it "returns a JSON object of access details from figures" do
        expect(supporting_information_task.file_access_details).to eq [:hello]
      end
    end
  end
end
