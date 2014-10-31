FactoryGirl.define do
  factory :figure_task, class: 'StandardTasks::FigureTask' do
    phase
    title "Upload Figures"
    role "author"
  end
end
