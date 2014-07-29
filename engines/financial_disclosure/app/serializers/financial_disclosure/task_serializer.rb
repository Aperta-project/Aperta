module FinancialDisclosure
  class TaskSerializer < ::TaskSerializer
    has_many :funders, embed: :ids, include: true
  end
end
