# coding: utf-8
FactoryGirl.define do
  factory :reviewer_report do
    decision
    user
    association :task, factory: :reviewer_report_task
  end
end
