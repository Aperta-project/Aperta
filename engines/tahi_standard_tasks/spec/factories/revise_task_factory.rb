FactoryGirl.define do
  factory :revise_task, class: 'TahiStandardTasks::ReviseTask' do
    phase
    title "Revise Manusript"
    role "author"
  end
end
