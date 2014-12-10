require "spec_helper"

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
