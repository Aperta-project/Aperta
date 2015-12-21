FactoryGirl.define do
  factory :revise_task, class: 'TahiStandardTasks::ReviseTask' do
    phase
    title "Revise Manusript"
    old_role "author"
  end
end
