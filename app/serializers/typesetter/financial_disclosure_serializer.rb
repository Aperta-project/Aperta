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
