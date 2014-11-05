FactoryGirl.define do
  factory :financial_disclosure_task, class: 'StandardTasks::FinancialDisclosureTask' do
    phase
    title "Financial Disclosure"
    role "author"
  end
end
