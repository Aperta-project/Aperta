require 'rails_helper'

describe GenericMailer do
  describe '#send_email' do
    let(:email) do
      GenericMailer.send_email(
        subject: 'this is the subject',
        body: "this is <br>the\nbody",
        to: 'bob@example.com'
      )
    end

    it 'has correct Subject line' do
      expect(email.subject).to eq 'this is the subject'
    end

    it 'has correct To recipients' do
      expect(email.to).to contain_exactly 'bob@example.com'
    end

    describe 'plain/text body' do
      it 'substitutes each <br> tags with two newlines' do
        expect(email.text_part.body.to_s).to include "this is \n\nthe\nbody"
      end
    end

    describe 'html body' do
      it 'substitutes newlines with <br> tags' do
        expect(email.html_part.body.to_s).to include "this is <br>the<br>body"
      end
    end
  end
end
