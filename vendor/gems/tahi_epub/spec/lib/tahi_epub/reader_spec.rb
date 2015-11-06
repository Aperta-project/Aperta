require 'spec_helper'
require_relative '../../../lib/tahi_epub/reader.rb'

describe TahiEpub::Reader do
  let(:epub_fixture) { File.read('./spec/fixtures/turtles.epub') }

  describe '#source' do
    context "when called with a block" do
      it "accepts an epub stream and opens a tempfile for modification" do
        TahiEpub::Reader.new(stream: epub_fixture).source do |tmpfile|
          expect(tmpfile).to be_a Tempfile
        end
      end
    end

    context "when called without a block" do
      it "accepts an epub stream and returns a tempfile" do
        stream = TahiEpub::Reader.new(stream: epub_fixture).source
        expect(stream).to be_a Tempfile
      end
    end

    context "with a valid stream" do
      let(:stream) { epub_fixture }
      it "accepts an epub stream and creates a tempfile" do
        TahiEpub::Reader.new(stream: stream).source do |tmpfile|
          expect(tmpfile).to be_a Tempfile
          expect(tmpfile.length).to eq 64098
        end
      end
    end

    context "when the stream is empty" do
      let(:stream) { nil }
      it "raises a TahiEpub::FileNotFoundError" do
        expect do
          TahiEpub::Reader.new(stream: stream).source { nil } #noop block
        end.to raise_error(TahiEpub::FileNotFoundError)
      end
    end

    context "when the stream is not a file" do
      let(:stream) { "garbage" }
      it "raises a TahiEpub::FileNotFoundError" do
        expect do
          TahiEpub::Reader.new(stream: stream).source { nil }
        end.to raise_error(TahiEpub::FileNotFoundError)
      end
    end
  end

  describe "#content" do
    let(:file) { File.open(File.expand_path('../../../fixtures/equations.epub', __FILE__)).read }

    it "returns OEBPS/content.html from the ePub" do
      expect(TahiEpub::Reader.new(stream: file).content).to_not be_nil
      expect(TahiEpub::Reader.new(stream: file).content).to be_kind_of(String)
    end
  end
end
