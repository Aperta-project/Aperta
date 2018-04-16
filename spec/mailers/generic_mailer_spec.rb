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
