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

describe Verifier do
  describe "#encrypt" do
    let(:payload) { { paper_id: "33" } }

    context "provided an expiration date" do
      let(:encrypted_data) { Verifier.new(payload).encrypt(expiration_date: 2.days.from_now) }

      it "encrypts the expiration date" do
        decrypter = Verifier.new(encrypted_data)
        expect(decrypter.expiration_date).to be_present
      end
    end

    context "provided no expiration date" do
      let(:encrypted_data) { Verifier.new(payload).encrypt }

      it "does not include an expiration date" do
        decrypter = Verifier.new(encrypted_data)
        expect(decrypter.expiration_date).to_not be_present
      end
    end

    context "provided an expiration date and data is not a hash" do
      let(:payload) { "a string" }

      it "raises an error" do
        expect{ Verifier.new(payload).encrypt(expiration_date: 2.days.from_now) }.to raise_error(InvalidPayload)
      end
    end
  end

  describe "#decrypt" do
    let(:payload) { { paper_id: "33" } }

    context "payload includes an expired expiration date" do
      let(:encrypted_data) { Verifier.new(payload).encrypt(expiration_date: 2.days.ago) }

      it "raises an error" do
        decrypter = Verifier.new(encrypted_data)
        expect{ decrypter.decrypt }.to raise_error(MessageExpired)
      end
    end

    context "payload includes a future expiration date" do
      let(:encrypted_data) { Verifier.new(payload).encrypt(expiration_date: 2.days.from_now) }

      it "decrypts the data without the expiration date" do
        decrypter = Verifier.new(encrypted_data)
        expect(decrypter.decrypt).to eq(payload)
      end
    end

    context "payload does not include expiration date" do
      let(:encrypted_data) { Verifier.new(payload).encrypt }

      it "decrypts the data" do
        decrypter = Verifier.new(encrypted_data)
        expect(decrypter.decrypt).to eq(payload)
      end
    end
  end
end
