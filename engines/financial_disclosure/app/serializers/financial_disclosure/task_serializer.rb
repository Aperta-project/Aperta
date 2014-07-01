module FinancialDisclosure
  class TaskSerializer < ::TaskSerializer
    has_many :funders, embed: :ids, include: true
    has_many :questions, embed: :ids, include: true
  end
end
