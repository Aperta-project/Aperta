module Typesetter
  # Serializes the financial disclosure task for the typesetter.
  # Expects a financial disclosure task as its object to serialize.
  class FinancialDisclosureSerializer < Typesetter::TaskAnswerSerializer
    attribute :author_received_funding

    has_many :funders, serializer: Typesetter::FunderSerializer

    def author_received_funding
      task_answer_value(object, 'financial_disclosures--author_received_funding')
    end
  end
end
