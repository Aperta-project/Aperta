require 'rails_helper'

describe AmazonS3Signer do
  describe '#params' do
    let(:signer) do
      AmazonS3Signer.new(file_name: 'test.png',
                         file_path: 'paper/figures123456789',
                         content_type: 'image/png')
    end

    it 'contains the specified url' do
      Timecop.freeze do
        params = signer.params
        expect(params[:acl]).to eq('public-read')
        expect(params[:awsaccesskeyid]).to eq('ur-id')
        expect(params[:bucket]).to eq('tahi-test')
        expect(params[:expires]).to eq(Time.current + 1.day)
        expect(params[:key]).to eq('paper/figures123456789/test.png')
        expect(params[:success_action_status]).to eq('201')
        expect(params['Content-Type']).to eq('image/png')
        expect(params['Cache-Control']).to eq('max-age=630720000, public')
        expect(params[:signature]).to_not be_nil
      end
    end

    context 'the policy object' do
      let(:policy) { JSON.parse(Base64.decode64(signer.params[:policy])) }

      it 'should not have any newlines or returns after base64 encoding' do
        expect(policy).not_to match(/\n|\r/)
      end

      it 'has an expiration key whose value is a date-time string' do
        expect(DateTime.iso8601(policy['expiration'])).to_not be_nil
      end

      context 'conditions' do
        let(:conditions) { policy['conditions'] }

        it 'contains the bucket' do
          expect(conditions).to include('bucket' => 'tahi-test')
        end

        it 'specifies the acl as public-read' do
          expect(conditions).to include('acl' => 'public-read')
        end

        it 'specifies success_action_status to be 201' do
          expect(conditions).to include('success_action_status' => '201')
        end
      end
    end
  end
end
