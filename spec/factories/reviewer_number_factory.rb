FactoryGirl.define do
  # This trait is building a task but using FactoryGirl stubs for associations
  # it normally depends on. This reduces the time it takes to construct the
  # task.
  factory :reviewer_number do
    paper
    user
  end
end
