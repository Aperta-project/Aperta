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
