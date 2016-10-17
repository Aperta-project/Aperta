require 'rails_helper'

describe GenericMailer do
  describe '#send_email' do
    let(:email) do
      GenericMailer.send_email(
        subject: 'this is the subject',
        body: 'this is <br> the body',
        to: 'bob@example.com'
      )
    end

    it 'has correct Subject line' do
      expect(email.subject).to eq 'this is the subject'
    end

    it 'has correct To recipients' do
      expect(email.to).to contain_exactly 'bob@example.com'
    end

    it 'uses the given :body as the html body' do
      expect(email.html_part.body.to_s).to include 'this is <br> the body'
    end

    it 'uses the given :body minus <br> tags as the plain/text body' do
      expect(email.text_part.body.to_s).to include "this is \n\n the body"
    end
  end
end
