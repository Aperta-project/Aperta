FactoryGirl.define do
  factory :message_task do
    title "a subject" # should match subject
  end

  factory :comment do
    body "HEY"
  end

  factory :survey do
    question "What is the cake?"
    answer "A lie!"
  end

  factory :manuscript_manager_template do
    name 'Sample Template'
    paper_type 'Research'
    template { {} }

  end

end
