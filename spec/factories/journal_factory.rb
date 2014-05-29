FactoryGirl.define do
  factory :journal do
    sequence :name do |n|
      "Journal #{n}"
    end
    manuscript_manager_templates { [create(:manuscript_manager_template), create(:manuscript_manager_template)] }

    trait :with_default_template do
      # manuscript_manager_templates { [DefaultManuscriptManagerTemplateFactory.build()] }
    end
  end
end
