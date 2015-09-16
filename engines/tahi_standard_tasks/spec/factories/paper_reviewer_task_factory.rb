FactoryGirl.define do
  factory :paper_reviewer_task, class: 'TahiStandardTasks::PaperReviewerTask' do
    phase
    title "Invite Reviewers"
    role "reviewer"
  end
end
