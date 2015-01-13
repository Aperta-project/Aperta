require 'rails_helper'

describe S3FormConfigurator do
  describe "form_json" do
    let(:default_s3_params) do
      {url: "testUrl",
       aws_key: "foo",
       aws_secret: "bar",
       bucket_name: "aBucket",
       upload_path: "files/pictures",
       content_type: "jpeg"}
    end

    let(:configurator) { S3FormConfigurator.new(default_s3_params) }

    it "contains the specified url" do
      expect(configurator.url).to eq("testUrl")
    end

    it "has the aws key" do
      expect(configurator.access_key_id).to eq("foo")
    end

    it "specifies the acl as 'public read'" do
      expect(configurator.acl).to eq("public-read")
    end

    it "allows default parameters to be overwritten" do
      configurator = S3FormConfigurator.new(default_s3_params) do
        self.acl = "public-write"
      end
      expect(configurator.acl).to eq("public-write")
    end

    it "generates a key that starts with the specified upload_path." do
      s3_params = default_s3_params.merge({upload_path: "files/pictures/"})
      configurator = S3FormConfigurator.new(s3_params)
      expect(configurator.key).to match(/^files\/pictures/)
    end

    it "generates a key that is a combination of the specified upload path and a random token" do
      configurator_1 = S3FormConfigurator.new(default_s3_params)
      configurator_2 = S3FormConfigurator.new(default_s3_params)

      key1 = configurator_1.key
      key2 = configurator_2.key

      expect(key1).to_not eq(key2)
    end


    context "the policy object" do
      let(:policy) { JSON.parse(Base64.decode64(configurator.policy)) }

      it "shouldn't have any newlines or carriage returns after base64 encoding" do
        expect(configurator.policy).not_to match(/\n|\r/)
      end

      it "has an expiration key whose value is a date-time string" do
        expect(DateTime.iso8601(policy["expiration"])).to_not be_nil
      end

      context "policy conditions" do
        it "contains the bucket" do
          expect(policy["conditions"]).to include({"bucket" => "aBucket"})
        end

        it "specifies the acl as public-read" do
          expect(policy["conditions"]).to include({"acl" => "public-read"})
        end

        it "specifies that the key should start with the root of the specified upload path" do
          expect(policy["conditions"]).to include(["starts-with", "$key", "files/"])
        end

        it "specifies conditions the content type" do
          expect(policy["conditions"]).to include(["eq", "$Content-Type", "jpeg"])
        end

        it "specifies success_action_status to be '201'" do
          expect(policy["conditions"]).to include({'success_action_status' => '201'})
        end
      end
    end

    context "the signature" do
      it "The signature should use the policy and s3 secret to create a base64 encoded digest" do
        reference = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'),
                                         "bar",
                                         configurator.policy)
        encoded_reference = Base64.encode64(reference).gsub(/\n|\r/, '')

        expect(configurator.signature).to eq(encoded_reference)
      end
    end
  end
end
