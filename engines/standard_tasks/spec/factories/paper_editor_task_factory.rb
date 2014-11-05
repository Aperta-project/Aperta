FactoryGirl.define do
  factory :paper_editor_task, class: 'StandardTasks::PaperEditorTask' do
    phase
    title "Assign Editor"
    role "admin"
  end
end
