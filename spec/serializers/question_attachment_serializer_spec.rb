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

describe QuestionAttachmentSerializer, serializer_test: true do
  let(:attachment) do
    FactoryGirl.create(
      :question_attachment,
      :with_resource_token,
      title: 'La Attachment',
      file: File.open('spec/fixtures/yeti.tiff'),
      status: QuestionAttachment::STATUS_DONE
    )
  end
  let(:object_for_serializer) { attachment }

  it 'should serialize succesfully' do
    expect(attachment.id).to_not be(nil)
    expect(attachment.title).to_not be(nil)
    expect(attachment.src).to_not be(nil)
    expect(attachment.status).to_not be(nil)
    expect(attachment.filename).to_not be(nil)

    expect(deserialized_content)
      .to match(
        hash_including(
          question_attachment:
            hash_including(
              id: attachment.id,
              title: attachment.title,
              src: attachment.src,
              status: attachment.status,
              filename: attachment.filename
            )
        )
      )
  end
end
