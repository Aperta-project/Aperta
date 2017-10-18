# coding: utf-8

FactoryGirl.define do
  factory :reviewer_report do
    decision
    user
    card_version
    association :task, factory: :reviewer_report_task
    association :due_datetime, :in_5_days
    submitted_at DateTime.current
  end
end
