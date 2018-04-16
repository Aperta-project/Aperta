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

# Convenience factory for creating CardContent with answers
class AnswerableFactory
  class << self
    def create(owner, questions:, card: nil)
      card = card.presence || Card.find_by(name: owner.class.name) ||
        FactoryGirl.create(:card, :versioned, name: owner.class.name)
      create_questions(questions, owner: owner, card: card, parent: card.content_root_for_version(:latest))
      owner
    end

    def create_questions(questions, parent: nil, owner: nil, card:)
      questions.each do |question_hash|
        question = create_question(question_hash, parent, owner, card)
        create_answer(question_hash, question, owner)
        next unless question_hash[:questions]
        create_questions(
          question_hash[:questions],
          parent: question,
          owner: owner,
          card: card
        )
      end
    end

    def create_question(question_hash, parent, _owner, card)
      card_content = CardContent.find_by(ident: question_hash[:ident]) ||
        FactoryGirl.build(:card_content)

      card_content.tap do |cc|
        cc.parent = parent
        cc.card_version = card.latest_published_card_version
        cc.text = question_hash[:text]
        cc.ident = question_hash[:ident]
        cc.value_type = question_hash[:value_type]
        cc.save!
      end
    end

    def create_answer(question_hash, question, owner)
      FactoryGirl.create(
        :answer,
        card_content: question,
        owner: owner,
        value: question_hash[:answer],
        repetition: question_hash[:repetition],
        paper: owner.paper
      )
    end
  end
end
