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

# This class is responsible for aggregating the funding statement message by looking at
# all Funders on a paper.
class FinancialDisclosureStatement
  REPEAT_IDENT = 'funder--repeat'.freeze
  AUTHOR_RECEIVED_FUNDING_IDENT = 'financial_disclosures--author_received_funding'.freeze

  def initialize(paper, answers = nil)
    @paper = paper
    @answers = answers
  end

  def funding_statement
    statement = funders.map(&:funding_statement).join(";\n")
    statement.presence || "The author(s) received no specific funding for this work."
  end

  def funders
    @funders ||= funder_repetitions.order(position: :asc).map do |rep|
      Funder.new(answers, rep)
    end
  end

  def asked?
    Task.joins(card_version: :card_contents)
        .where(card_contents: { ident: AUTHOR_RECEIVED_FUNDING_IDENT })
        .where(paper: @paper)
        .exists?
  end

  private

  def funder_repetitions
    @funder_repetitions ||= Repetition.joins(:card_content)
                                      .where(card_contents: { ident: REPEAT_IDENT }, task: @paper.tasks)
  end

  def answers
    @answers ||= Answer.where(repetition_id: funder_repetitions).includes(:card_content, :repetition)
  end

  def answer_for(ident, repetition)
    answers.detect { |answer|
      answer.card_content.ident == ident && answer.repetition == repetition
    }.try!(:value)
  end
end
