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
require 'subscriptions/console_formatter'

describe Subscriptions::ConsoleFormatter do
  let(:formatter) { described_class.new(headers, rows) }

  context "header character length equals row character length" do
    let(:headers) {  ["header1", "header2"] }
    let(:rows)    { [["data111", "data222"]] }

    it "output has no additional padding" do
      result = "header1 header2\ndata111 data222\n"
      expect(formatter.to_s).to eq(result)
    end
  end

  context "header character length larger than row character length" do
    let(:headers) {  ["header1", "header2"] }
    let(:rows)    { [["data1",   "data2"]] }

    it "row output is padded to match header length" do
      result = "header1 header2\ndata1   data2  \n"
      expect(formatter.to_s).to eq(result)
    end
  end

  context "header character length less than row character length" do
    let(:headers) {  ["header1",   "header2"] }
    let(:rows)    { [["data12345", "data23456"]] }

    it "header output is padded to match row output length" do
      result = "header1   header2  \ndata12345 data23456\n"
      expect(formatter.to_s).to eq(result)
    end
  end
end
