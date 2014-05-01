FactoryGirl.define do
  factory :journal do
    sequence :name do |n|
      "Journal #{n}"
    end
    manuscript_manager_templates { [create(:manuscript_manager_template)] }
  end
end
