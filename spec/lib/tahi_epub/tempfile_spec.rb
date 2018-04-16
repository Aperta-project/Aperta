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

describe TahiEpub::Tempfile do
  describe ".create" do
    it "creates a binary tempfile with the given stream" do
      contents = "Hello World"
      file_contents = TahiEpub::Tempfile.create(contents) do |file|
        File.open(file.path).read
      end

      expect(contents).to eq(file_contents)
    end

    it "returns the value from the block" do
      return_value = TahiEpub::Tempfile.create("Hello World") do |_file|
        1234
      end

      expect(return_value).to eq(1234)
    end

    it "deletes the created tempfile afterwards" do
      file = TahiEpub::Tempfile.create("Testing") do |file|
        file
      end

      expect(file).to be_closed
      expect(file.path).to be_nil
    end

    context "when an error is raised" do
      it "ensures the file is closed and deleted" do
        file = TahiEpub::Tempfile.create("Testing") do |file|
          begin
            raise StandardError
          rescue StandardError
            file
          end
        end

        expect(file).to be_closed
        expect(file.path).to be_nil
      end
    end
  end
end
