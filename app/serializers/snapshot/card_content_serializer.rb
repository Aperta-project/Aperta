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

class Snapshot::CardContentSerializer
  def initialize(card_content, owner, repetition = nil)
    @card_content = card_content
    @owner = owner
    @repetition = repetition
    @answer = fetch_answer
  end

  def as_json
    {
      name: @card_content.ident,
      type: 'question',
      value: {
        id: @card_content.id,
        title: @card_content.text,
        answer_type: @card_content.value_type,
        answer: @answer.try(:value),
        attachments: serialized_attachments_json
      },
      children: serialized_children_json
    }
  end

  private

  def serialized_children_json
    if @card_content.content_type == "repeat"
      @card_content.repetitions.where(task: @owner, parent: @repetition).order(:position).flat_map do |repetition|
        @card_content.children.map do |child|
          Snapshot::CardContentSerializer.new(child, @owner, repetition).as_json
        end
      end
    else
      @card_content.children.flat_map do |child|
        Snapshot::CardContentSerializer.new(child, @owner, @repetition).as_json
      end
    end
  end

  def serialized_attachments_json
    attachments = []
    attachments = @answer.attachments if @answer
    attachments.map do |attachment|
      Snapshot::AttachmentSerializer.new(attachment).as_json
    end
  end

  def fetch_answer
    @owner.answers
      .where(card_content: @card_content, repetition: @repetition)
      .first
  end
end
