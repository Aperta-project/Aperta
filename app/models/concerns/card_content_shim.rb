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

# This module is intended to be mixed into ActiveModel::Serializer
# subclasses that are serializing their card content as 'nested_questions'
module CardContentShim
  extend ActiveSupport::Concern

  included do
    has_many :nested_questions,
             serializer: CardContentAsNestedQuestionSerializer,
             embed: :ids,
             include: true
    has_many :nested_question_answers,
             serializer: AnswerAsNestedQuestionAnswerSerializer,
             embed: :ids,
             include: true

    def nested_questions
      object.card.try(:content_for_version_without_root, :latest) || []
    end

    def nested_question_answers
      object.answers
    end
  end
end
