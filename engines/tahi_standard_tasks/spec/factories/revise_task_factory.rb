FactoryGirl.define do
  factory :revise_task, class: 'TahiStandardTasks::ReviseTask' do
    paper
    phase
    card_version
    title "Revise Manusript"
  end
end
