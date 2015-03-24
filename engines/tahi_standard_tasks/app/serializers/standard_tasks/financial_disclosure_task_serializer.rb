module TahiStandardTasks
  class FinancialDisclosureTaskSerializer < ::TaskSerializer
    has_many :funders, embed: :ids, include: true
  end
end
