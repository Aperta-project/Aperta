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
