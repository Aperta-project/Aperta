FactoryGirl.define do

  factory :manuscript_manager_template do
    sequence(:paper_type) {|n| "Research #{n}" }
    journal
  end

end
