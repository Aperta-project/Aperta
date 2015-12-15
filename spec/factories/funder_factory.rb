FactoryGirl.define do
  factory :funder, class: TahiStandardTasks::Funder do
    task
    sequence(:grant_number){ |n| "10000#{n}" }
    name         "Leia Organa-Solo"
    website      "http://alderaan.gov"
  end
end
