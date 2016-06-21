FactoryGirl.define do
  factory :paper_reviewer_task, class: 'TahiStandardTasks::PaperReviewerTask' do
    paper
    phase
    title 'Invite Reviewers'
    old_role 'editor'
  end
end
