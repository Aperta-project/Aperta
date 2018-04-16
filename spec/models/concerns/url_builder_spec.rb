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

describe UrlBuilder do
  # mixed in url_builder concern
  let(:model){ class FakeModel; include UrlBuilder; end; }

  describe "#url_for" do
    it "will generate a url for a valid resource path" do
      expect(Rails.configuration.action_mailer.default_url_options[:host]).to eq("www.example.com")
      expect(model.new.url_for(:root)).to eq("http://www.example.com/")
    end

    it "allows routing options to be overridden" do
      options = { host: "foo.com", port: "8080" }
      expect(model.new.url_for(:root, options)).to eq("http://foo.com:8080/")
    end
  end
end
