FactoryGirl.define do
  factory :revise_task, class: 'TahiStandardTasks::ReviseTask' do
    paper
    phase
    title "Revise Manusript"
    old_role "author"
  end
end
