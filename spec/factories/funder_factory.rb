FactoryGirl.define do
  factory :funder, class: TahiStandardTasks::Funder do
    association :task, factory: :adhoc_task
    sequence(:grant_number) { |n| "10000#{n}" }
    name         "Leia Organa-Solo"
    website      "http://alderaan.gov"
  end
end
