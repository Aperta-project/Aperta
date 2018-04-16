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

# Answerable brings together a few bundled concepts, including belonging to a
# Card and owning Answers.  Anything that can store the Answer to a piece of
# CardContent also belongs to a Card.
module Answerable
  extend ActiveSupport::Concern

  module ClassMethods
    def answerable?
      true
    end
  end

  included do
    belongs_to :card_version
    has_one :card, through: :card_version
    has_many :answers, as: :owner, dependent: :destroy

    delegate :latest_published_card_version, to: :card, allow_nil: true

    validates :card_version_id, presence: true

    before_validation :set_card_version

    def owner_type_for_answer
      self.class.name
    end

    def answer_for(ident)
      answers.joins(:card_content).find_by(card_contents: { ident: ident })
    end

    # when a new Answerable model is being created, this is the
    # Card that is used to determine the correct CardVersion.
    # This method can be overriden by the model, if a custom lookup
    # is necesssary.
    def default_card
      Card.find_by_class_name!(self.class.name)
    end

    # find_or_build_answer_for(...) will return the associated answer for this
    # task given the :card_content parameter.
    def find_or_build_answer_for(card_content:, value: nil, repetition: nil)
      answer = answers.find_or_initialize_by(
        card_content: card_content,
        value: value,
        repetition: repetition
      )
      answer.paper = paper if respond_to?(:paper)

      answer
    end

    private

    # when new card versions are being created, associate the Answerable
    # model to the latest version of the Card.
    def set_card_version
      self.card_version ||= default_card.try(:latest_published_card_version)
    end
  end
end
