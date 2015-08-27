FactoryGirl.define do
  factory :paper_reviewer_task, class: 'TahiStandardTasks::PaperReviewerTask' do
    phase
    title "Invite Reviewers"
    role "editor"
  end
end
