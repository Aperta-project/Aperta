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

describe ApiKey do
  describe "#generate_access_token" do

    it "returns a random access token" do
      api_key = ApiKey.create!
      expect(api_key.access_token).to_not be_nil
      expect(api_key.access_token.length).to eq(32)
    end

    context "when the randomly generated token is present" do
      before do
        ApiKey.create!.update_attribute :access_token, 'duplicate_token'
        allow(SecureRandom).to receive(:hex).and_return('duplicate_token', 'something_unique')
      end

      it "will create another token if there exists a duplicate" do
        expect(SecureRandom).to receive(:hex).twice
        ApiKey.create!
      end
    end

  end
end
