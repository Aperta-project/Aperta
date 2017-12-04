module Typesetter
  # Serializes the financial disclosure task for the typesetter.
  # Expects a financial disclosure task as its object to serialize.
  class FinancialDisclosureSerializer < Typesetter::TaskAnswerSerializer
    attribute :author_received_funding
    attribute :funding_statement

    has_many :funders, embed: :objects, serializer: Typesetter::FunderSerializer

    def author_received_funding
      answer_for('financial_disclosures--author_received_funding', nil)
    end

    def funding_statement
      financial_disclosure_statement.funding_statement
    end

    def funders
      financial_disclosure_statement.funders
    end

    private

    def financial_disclosure_statement
      @finacial_disclosure_statement ||= FinancialDisclosureStatement.new(object.paper, answers)
    end
  end
end
