FactoryGirl.define do
  factory :revise_task, class: 'TahiStandardTasks::ReviseTask' do
    paper
    phase
    title "Revise Manusript"
  end
end
