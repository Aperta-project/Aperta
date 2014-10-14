FactoryGirl.define do
  factory :task do
    title "Do something awesome"
    role 'admin'
    phase

    trait :with_participant do
      participants { [FactoryGirl.create(:user)] }
    end
  end

  factory :message_task do
    title "a subject"
    phase
    participants { [FactoryGirl.create(:user)] }
  end

  factory :reviewer_report_task, class: 'StandardTasks::ReviewerReportTask' do
    phase
  end

  factory :paper_reviewer_task, class: 'StandardTasks::PaperReviewerTask' do
    phase
  end

  factory :register_decision_task, class: 'StandardTasks::RegisterDecisionTask' do
    phase
  end
end
